//
//  GenericDocumentSceneDelegate.swift
//  CommonUI
//
//  Created by Ben Spratling on 4/4/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit



open class GenericDocumentSceneDelegate<DocumentController, Document> : UIResponder, UIWindowSceneDelegate where DocumentController : UIDocumentViewController<Document> {
	
	public var window: UIWindow?
	
	//MARK: - UISceneDelegate
	
	open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: 	UIScene.ConnectionOptions) {
//		print("willConnectTo")
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			if !configure(window: window, with: userActivity, session: session) {
//				print("Failed to restore from \(userActivity)")
			}
		} else if connectionOptions.urlContexts.count > 0 {
			self.scene(scene, openURLContexts: connectionOptions.urlContexts)
		} else {
//			print("did not know what to do to connect to the session")
		}
		
		// If there were no user activities, we don't have to do anything.
		// The `window` property will automatically be loaded with the storyboard's initial view 	controller.
	}
	
	
	open func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
		let activity = existingDocumentViewController()?.userActivity
//		print("stateRestorationActivity(for scene, activity = \(activity), doc url = \(activity?.documentUrl)")
		return activity
	}
	
	open func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//		print("scene:\(scene) openURLContexts:\(URLContexts)")
		guard let urlContext:UIOpenURLContext = URLContexts.first
			  ,let docBrowser = window?.rootViewController as? GenericDocumentBrowserViewController<DocumentController, Document>
		else {
//			print("either no url context or rootview controller was not ")
			return }
		let importIfNeeded = !urlContext.options.openInPlace
		scene.session.userInfo = ["importIfNeeded":importIfNeeded]
		docUrlNeedsStopAccessingSecurityScope = urlContext.url.startAccessingSecurityScopedResource()
		docBrowser.revealDocument(at: urlContext.url, importIfNeeded: !urlContext.options.openInPlace) { (revealedDocumentURL, error) in
			if let error = error {
				// Handle the error appropriately
//				print("Failed to reveal the document at URL \(urlContext.url) with error: '\(error)'")
//				return	//apparently, this may be fine.
			}
			let docUrl = revealedDocumentURL ?? urlContext.url
			docBrowser.presentDocument(at: docUrl, animated: false, restoringFrom: nil, completion: nil)
		}
	}
	
	private var docUrlNeedsStopAccessingSecurityScope:Bool = false
	
	open func sceneDidBecomeActive(_ scene: UIScene) {
//		print("sceneDidBecomeActive \(scene)")
//		print("is window key \(window?.isKeyWindow == true)")
		if let docViewController = existingDocumentViewController() {
			if docViewController.document.documentState.contains(.closed) {
				docViewController.document.open { (success) in
//					print("sceneDidBecomeActive opening doc success = \(success)")
				}
			}
		} else {
			if let userActivity = scene.session.stateRestorationActivity {
//				print("calling configure(window: from sceneDidBecomeActive, but window?.rootViewController?.presentedViewController = \(window?.rootViewController?.presentedViewController)")
				if !configure(window: window, with: userActivity, session:scene.session) {
					//TODO: write me
//					print("Failed to configure from \(userActivity)")
				}
			}
		}
	}
	
	open func sceneWillResignActive(_ scene: UIScene) {
//		print("sceneWillResignActive")
		//		saveDocIfNeeded()
		closeDocIfPossible()
	}
	
	
	//MARK: -  Utilities
	
	open func configure(window: UIWindow?, with activity: NSUserActivity, session:UISceneSession) -> Bool {
//		print("configure window")
		guard let url = activity.documentUrl ?? activity.targetContentUrl else {
//			print("documentUrl was nil, userInfo == \(activity.userInfo)")
			return false
		}
		
		guard let docBrowser = window?.rootViewController as? GenericDocumentBrowserViewController<DocumentController, Document>
		else {
//			print("window's rootview controller was not a geneic doc browsing window")
			return false
		}
		docUrlNeedsStopAccessingSecurityScope = url.startAccessingSecurityScopedResource()
		let importIfNeeded:Bool = session.userInfo?["importIfNeeded"] as? Bool ?? true
//		print("docBrowser.revealDocument(at: \(url)")
//		docBrowser.presentDocument(at: url, animated:false)
		docBrowser.revealDocument(at: url, importIfNeeded:importIfNeeded) { (revealedDocumentURL, error) in
			if let docError = error {
				// Handle the error appropriately
//				print("Failed to reveal the document at URL \(url) with error: '\(docError)'")
				//um, what do I do here?
//				return	//it's ok for the doc browser to fail to reveal the doc, we can still try to open it
			}
			let docUrl = revealedDocumentURL ?? url
			docBrowser.presentDocument(at: docUrl, animated:false, restoringFrom: activity, completion: nil)
		}
		return true
	}
	
	open func isWindowConfigured()->Bool {
		return existingDocumentViewController() != nil
	}
	
	open func existingDocumentViewController()->DocumentController? {
		return window?.rootViewController?.presentedViewController as? DocumentController
	}
	
	open func closeDocIfPossible() {
		if let showDocVC = window?.rootViewController?.presentedViewController as? DocumentController {
//			print("closeDocIfPossible closed == \(showDocVC.document.documentState.contains(.closed))")
			showDocVC.document.close { (didClose) in
				if self.docUrlNeedsStopAccessingSecurityScope {
					showDocVC.document.fileURL.stopAccessingSecurityScopedResource()
				}
			}
		}
	}
	
}



extension NSUserActivity {
	var targetContentUrl:URL? {
		guard let string = targetContentIdentifier else { return nil}
		return URL(string: string)
	}
}
