//
//  UIDocumentViewController.swift
//  CommonUI
//
//  Created by Ben Spratling on 3/7/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit


open class UIDocumentViewController<Document> : BannerViewController where Document : ErrorRememberingDocument {
	
	public var document:Document
	
	public required init(document:Document, userDidClose:@escaping(UIViewController)->()) {
		self.userDidClose = userDidClose
		self.document = document
		super.init(nibName: nil, bundle: nil)
		documentStateChangedObserver = NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: document, queue: nil, using: { [weak self] (_) in
			self?.reloadDocumentDataIfNeeded()
		})
	}
	
	///override me
	open var userActivityIdentifier:String { return "" }
	
	open var userDidClose:(UIViewController)->()
	
	///DO NOT CALL
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var documentStateChangedObserver:NSObjectProtocol?
	
	open func updateDocumentUrlInTitleBar() {
		guard isViewLoaded else { return }
		view.window?.windowScene?.title = document.fileURL.lastPathComponent
		#if targetEnvironment(macCatalyst)
		view.window?.windowScene?.titlebar?.representedURL = document.fileURL
		#endif
	}
	
	open func reloadDocumentDataIfNeeded() {
		guard isViewLoaded
		else { return }
		if document.documentState.contains(.normal) {
			reloadDocumentData()
		}
		if document.documentState.contains(.savingError) {
			//			showErrorBanner(text: "Error saving doc.")
		}
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		reloadDocumentDataIfNeeded()
	}
	
	///override me - set up your ui as if a new document had been provided
	open func reloadDocumentData() {
		
	}
	
	///override me
	open func restoreFrom(_ activity:NSUserActivity?) {
		
	}
	
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateSceneRestoration()
	}
	
	
	open func userWillClose() {
		document.close { (_) in
			self.userDidClose(self)
		}
	}
	
	///the app will re-crete the NSUserActivity and inform the system of the change
	open func updateSceneRestoration() {
		updateDocumentUrlInTitleBar()
		updateStateRestorationWithCurrentDocumentActivity(documentUserActivity())
	}
	
	open func documentUserActivity()->NSUserActivity {
		let activity:NSUserActivity = NSUserActivity(activityType: userActivityIdentifier)
		activity.targetContentIdentifier = document.fileURL.absoluteString
		activity.title = document.fileURL.lastPathComponent
		activity.documentUrl = document.fileURL
		activity.isEligibleForHandoff = true
		activity.requiredUserInfoKeys = [activityDocumentUrlKey]
		return activity
	}
	
	open func updateStateRestorationWithCurrentDocumentActivity(_ activity:NSUserActivity) {
		defer {
			view.window?.windowScene?.userActivity = activity
		}
		guard isViewLoaded
			  ,let activationConditions = view.window?.windowScene?.activationConditions
		else { return }
		let url:URL = document.fileURL
		let escapedFileUrl = url.absoluteString.replacingOccurrences(of: "'", with: "\\'")
		activationConditions.canActivateForTargetContentIdentifierPredicate = NSPredicate(format: "self == '\(escapedFileUrl)'")
		activationConditions.prefersToActivateForTargetContentIdentifierPredicate = NSPredicate(format: "self == '\(escapedFileUrl)'")
		
		view.window?.windowScene?.activationConditions = activationConditions
	}
	
}
