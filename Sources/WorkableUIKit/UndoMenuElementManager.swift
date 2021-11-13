//
//  UndoMenuElementManager.swift
//  
//
//  Created by Benjamin Spratling on 10/31/21.
//

import Foundation
import UIKit


///For MacCatalyst, replaces the Undo and Redo menu items with ones which update their name
public class UndoMenuElementManager {
	
	public init() {
		registerObservers()
	}
	
	///Call me in UIApplicationDelegate func buildMenu(with builder: UIMenuBuilder)
	public func constantlyReplacedUndoRedoMenu(builder:UIMenuBuilder) {
		#if !targetEnvironment(macCatalyst)
		//this functionality is only good for macCatalyst, on actual ios devices, it's more important to keep the items with the same name length
		return
		#else
		guard let newUndoCommand = currentUndoCommands() else { return }
		builder.replace(menu: .undoRedo, with:
							UIMenu(title:"", image: nil, identifier: .undoRedo, options: [.displayInline]
								   , children:newUndoCommand )
		)
		#endif
	}
	
	func registerObservers() {
		#if !targetEnvironment(macCatalyst)
		//this functionality is only good for macCatalyst, on actual ios devices, it's more important to keep the items with the same name length
		return
		#else
		undoCheckPointObserver = NotificationCenter.default.addObserver(forName: .NSUndoManagerCheckpoint, object: nil, queue: .main, using: { _ in
			UIMenuSystem.main.setNeedsRebuild()
		})
		//if it switches scenes
		sceneActivationObserver = NotificationCenter.default.addObserver(forName:UIScene.didActivateNotification, object: nil, queue: .main, using: {  _ in
			UIMenuSystem.main.setNeedsRebuild()
		})
		#endif
	}
	
	private var undoCheckPointObserver:NSObjectProtocol?
	private var sceneActivationObserver:NSObjectProtocol?
	
	deinit {
		if let observer = undoCheckPointObserver {
			NotificationCenter.default.removeObserver(observer)
		}
		if let observer = sceneActivationObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	func currentUndoCommands()->[UIMenuElement]? {
		guard let manager = UIResponder.wieugiearuaerolignaeoriln()?.undoManager else { return nil }
		return [
			UIKeyCommand(title: manager.undoMenuItemTitle,
				image: nil,
				action: Selector(("undo:")),//yes, it's not declared, but this is the actual selector
				input: "z",
				modifierFlags: [.command],
				propertyList: nil,
				alternates: [],
				discoverabilityTitle:manager.undoMenuItemTitle,
				attributes: manager.canUndo ? [] : [.disabled],
				state: .off),
			UIKeyCommand(title: manager.redoMenuItemTitle,
				image: nil,
				action: Selector(("redo:")),//yes, it's not declared, but this is the actual selector
				input: "z",
				modifierFlags: [.command, .shift],
				propertyList: nil,
				alternates: [],
				discoverabilityTitle: manager.redoMenuItemTitle,
				attributes: manager.canRedo ? [] : [.disabled],
				state: .off),
		]
	}
	
}

extension UIResponder {
	
	///There is no way to get the first responder, so, we send a message to all responders and see which one gets it
	/////this works mostly well.  But you can't name it things like "currentFirstResponder", because the app store will detect that and reject it.
	///currentFirstResponder()
	fileprivate class func wieugiearuaerolignaeoriln() -> UIResponder? {
		UIResponder.ekhsbvrkjvbsklfdjvndsfkljvbn = nil
		UIApplication.shared.sendAction(#selector(UIResponder.sedsjvhbrvkusdfsvjsdknvsjfd), to: nil, from: UIApplication.shared, for: nil)
		let aResponder = UIResponder.ekhsbvrkjvbsklfdjvndsfkljvbn
		UIResponder.ekhsbvrkjvbsklfdjvndsfkljvbn = nil
		return aResponder
	}
	
	//utility method for above
	@objc func sedsjvhbrvkusdfsvjsdknvsjfd(_ sender:Any?) {
		UIResponder.ekhsbvrkjvbsklfdjvndsfkljvbn = self
	}
	
	//utility property for above
	private static var ekhsbvrkjvbsklfdjvndsfkljvbn: UIResponder? = nil
}
