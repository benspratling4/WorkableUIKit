//
//  GenericDocumentBrowserViewController.swift
//  CommonUI
//
//  Created by Ben Spratling on 4/4/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit
import UniformTypeIdentifiers



public enum DocumentBrowsingAction {
	///creates a new document by copying the template file you provide
	case newDocument(()->URL)
	
	///creates a UIDocument instance from the url
	case openDocument((URL)throws->UIDocument)
	
	///converts a file into a new format, and provides that url to the browser
	case convertDocument((URL)throws->(URL, UTType))
}



open class GenericDocumentBrowserViewController<DocumentController, Document> : UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate where DocumentController : UIDocumentViewController<Document> {
	
	public var documentActions:[Set<UTType>:DocumentBrowsingAction]?
	
	public var documentCreator:((@escaping((URL, UIDocumentBrowserViewController.ImportMode)?)->())->())? {
		didSet {
			allowsDocumentCreation = documentCreator != nil
		}
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		allowsPickingMultipleItems = false
	}
	
	open override func updateUserActivityState(_ activity: NSUserActivity) {
//		print("GenericDocumentBrowserViewController updateUserActivityState \(activity), userInfo = \(activity.userInfo)")
		super.updateUserActivityState(activity)
	}
	
	// MARK: Document Presentation
	
	open func presentDocument(at documentURL: URL, animated:Bool, restoringFrom:NSUserActivity?, completion:((Bool)->())?) {
//		print("presentDocument(at \(self)")
		let document = Document(fileURL: documentURL)
		document.undoManager = view.window?.undoManager
		let documentViewController = DocumentController(document:document
														,userDidClose: { vc in
															vc.dismiss(animated: true) { [weak self] in
																self?.userDismissedDocument()
															}
														})
		documentViewController.modalPresentationStyle = .fullScreen
//		print("document.open(...")
		document.open(completionHandler: { (success) in
//			print("document did open success = \(success)")
			if success {
				documentViewController.modalPresentationStyle = .fullScreen
				documentViewController.modalTransitionStyle = .crossDissolve
				let presentation = {
					self.present(documentViewController, animated: false, completion: {
	//					print("document open completed presentation")
						documentViewController.restoreFrom(restoringFrom)
						completion?(true)
					})
				}
				//sometimes the window hasn't laoded yet because apple sucks.
				if self.isViewLoaded
					, let window = self.view.window {
					presentation()
				}
				else {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
						presentation()
					}
				}
				
			}
			else if let error = document.error as? LocalizedError {
//				print("error opening document \(error)")
				let bodyText =  [error.failureReason, error.recoverySuggestion]
					.compactMap({ $0 })
					.joined(separator: "  ")
				let errorModal = UIAlertController(title: error.errorDescription, message: bodyText, preferredStyle: .alert)
				if let recoverableError = error as? RecoverableError {
					for (optionIndex, optionText) in recoverableError.recoveryOptions.enumerated() {
						errorModal.addAction(.init(title: optionText, style: .default, handler: { [weak self] _ in
							recoverableError.attemptRecovery(optionIndex: optionIndex) { recovered in
								completion?(recovered)
							}
							self?.dismiss(animated: true, completion: nil)
						}))
					}
				}
				errorModal.addAction(.init(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { [weak self] _ in
					self?.dismiss(animated: true, completion: {
						completion?(false)
				 })
				}))
				self.present(errorModal, animated: true, completion: nil)
				
			}
			else {
//				print("unknown error opening document")
				completion?(false)
			}
		})
	}
	
	
	open func userDismissedDocument() {
		#if targetEnvironment(macCatalyst)
		view.window?.windowScene?.titlebar?.representedURL = nil
		#else
		view.window?.windowScene?.title = nil
		#endif
		view.window?.windowScene?.activationConditions =  UISceneActivationConditions()
		view.window?.windowScene?.userActivity = nil
	}
	
	//MARK: - UIDocumentBrowserViewControllerDelegate
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
		guard let creator = documentCreator else {
			importHandler(nil, .none)
			return
		}
		creator({ urlAndModeOrNil in
			importHandler(urlAndModeOrNil?.0, urlAndModeOrNil?.1 ?? .none)
		})
	}
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
//		print("documentBrowser \(controller) didPickDocumentsAt")
		guard let sourceURL = documentURLs.first else { return }
		//check if an open scene should be focused instead
		let escapedFileUrl = sourceURL.absoluteString.replacingOccurrences(of: "'", with: "\\'")
		if let existingSession = UIApplication.shared
			.openSessions
			.filter({ session in
				guard let windowScene = session.scene as? UIWindowScene else { return false }
				let predicate:NSPredicate = windowScene.activationConditions.prefersToActivateForTargetContentIdentifierPredicate
				let prefers:Bool = predicate.evaluate(with: escapedFileUrl)
				return prefers
			})
			.first {
//			print("requestSceneSessionActivation( \(existingSession)")
			UIApplication.shared.requestSceneSessionActivation(existingSession, userActivity: nil, options: nil, errorHandler: nil)
			return
		}
		
		// Present the Document View Controller for the first document that was picked.
		// If you support picking multiple items, make sure you handle them all.
		presentDocument(at: sourceURL, animated:true, restoringFrom: nil, completion: nil)
	}
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		// Present the Document View Controller for the new newly created document
		presentDocument(at: destinationURL, animated:true, restoringFrom: nil, completion: nil)
	}
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
		// Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
		let errorMessage:String = error?.localizedDescription ?? NSLocalizedString("Failed to import the document", comment: "")
		let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
		present(alertController, animated: true, completion: nil)
		
	}
	
}



open class ErrorRememberingDocument : UIDocument {
	
	public override required init(fileURL url: URL) {
		self.error = nil
		super.init(fileURL: url)
	}
	
	//set after calls to open or save
	public var error:Error? = nil
	
	open override func handleError(_ error: Error, userInteractionPermitted: Bool) {
		self.error = error
		super.handleError(error, userInteractionPermitted: userInteractionPermitted)
	}

	open override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
		self.error = nil
		super.save(to: url, for: saveOperation, completionHandler: completionHandler)
	}
	
	open override func open(completionHandler: ((Bool) -> Void)? = nil) {
		self.error = nil
		super.open(completionHandler: completionHandler)
	}
}
