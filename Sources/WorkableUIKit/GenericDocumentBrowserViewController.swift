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
	
	// MARK: Document Presentation
	
	open func presentDocument(at documentURL: URL, animated:Bool) {
		let document = Document(fileURL: documentURL)
		document.undoManager = view.window?.undoManager
		let documentViewController = DocumentController(document:document
														,userDidClose: { vc in
															vc.dismiss(animated: true) { [weak self] in
																self?.userDismissedDocument()
															}
														})
		documentViewController.modalPresentationStyle = .fullScreen
		print("document.open(...")
		document.open(completionHandler: { (success) in
			if success {
				documentViewController.modalPresentationStyle = .fullScreen
				documentViewController.modalTransitionStyle = .crossDissolve
				self.present(documentViewController, animated: false, completion: nil)
			} else {
				
			}
		})
	}
	
	
	open func userDismissedDocument() {
		//TODO: more to do here?
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
		guard let sourceURL = documentURLs.first else { return }
		//check if an open scene should be focused instead
		let escapedFileUrl = sourceURL.absoluteString.replacingOccurrences(of: "'", with: "\\'")
		if let existingSession = UIApplication.shared
			.openSessions
			.filter({ ($0.scene as? UIWindowScene)?.activationConditions.prefersToActivateForTargetContentIdentifierPredicate.evaluate(with: escapedFileUrl) ?? false })
			.first {
			UIApplication.shared.requestSceneSessionActivation(existingSession, userActivity: nil, options: nil, errorHandler: nil)
			return
		}
		
		// Present the Document View Controller for the first document that was picked.
		// If you support picking multiple items, make sure you handle them all.
		presentDocument(at: sourceURL, animated:true)
	}
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		// Present the Document View Controller for the new newly created document
		presentDocument(at: destinationURL, animated:true)
	}
	
	open func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
		// Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
		let errorMessage:String = error?.localizedDescription ?? NSLocalizedString("Failed to import the document", comment: "")
		let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
		present(alertController, animated: true, completion: nil)
		
	}
	
}
