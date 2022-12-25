//
//  EmbeddedViewController.swift
//  SpratUIKitLeitmotifs
//
//  Created by Ben Spratling on 5/3/17.
//  Copyright © 2017 benspratling.com. All rights reserved.
//
import Foundation
import UIKit

///sets up another view controller to fill its view, forwards all status bar preferences to it
@objc open class EmbeddingViewController : UIViewController {
	
	
	@objc public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.definesPresentationContext = true
	}
	
	@objc public required init?(coder aDecoder: NSCoder) {
		//TODO: write me
		super.init(coder: aDecoder)
		self.definesPresentationContext = true
		
	}
	
	@objc open private(set) var embeddedViewController:UIViewController?
	
	@objc open func setEmbeddedViewController(_ viewController:UIViewController?, animations:UIView.AnimationOptions) {
		if viewController === embeddedViewController {
			return
		}
		let oldVC = embeddedViewController
		embeddedViewController?.willMove(toParent: nil)
		embeddedViewController = viewController
		
		guard let nextVC = viewController else {
			oldVC?.view.removeFromSuperview()
			oldVC?.removeFromParent()
			self.setNeedsStatusBarAppearanceUpdate()
			return
		}
		addChild(nextVC)
		//if !isViewLoaded { return }
		nextVC.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(nextVC.view)
		∫-nextVC.view-∫
		|-nextVC.view-|
		guard let originalVC = oldVC else {
			nextVC.didMove(toParent: self)
			self.setNeedsStatusBarAppearanceUpdate()
			return
		}
		originalVC.willMove(toParent: nil)
		
		let completion = {
			originalVC.view.removeFromSuperview()
			originalVC.removeFromParent()
			nextVC.didMove(toParent: self)
		}
		
		if animations.contains(.transitionCrossDissolve) {
			nextVC.view.alpha = 0.0
			UIView.animate(withDuration: 0.5, animations: {
				nextVC.view.alpha = 1.0
				self.setNeedsStatusBarAppearanceUpdate()
			}, completion:{ _ in
				completion()
			})
		} else {
			self.setNeedsStatusBarAppearanceUpdate()
			completion()
		}
	}
	
	@objc open override var childForStatusBarStyle: UIViewController? {
		return embeddedViewController?.childForStatusBarStyle ?? embeddedViewController
	}
	
	@objc open override var childForStatusBarHidden: UIViewController? {
		return embeddedViewController?.childForStatusBarHidden ?? embeddedViewController
	}
	
	@objc open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return embeddedViewController?.preferredStatusBarUpdateAnimation ?? .fade
	}
	
	@objc open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return embeddedViewController?.supportedInterfaceOrientations ?? .all
	}
	
	@objc open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return embeddedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
	}
	
}


extension UIViewController {
	
	public func dismissAllPresented(_ completion:@escaping()->()) {
		guard let presented = self.presentedViewController else {
			completion()
			return
		}
		presented.dismissAllPresented {
			presented.dismiss(animated: false) {
				self.dismissAllPresented(completion)
			}
		}
	}
	
	 public func ancestor<AncestorType>()->AncestorType? {
		 if let foundType = self as? AncestorType {
			 return foundType
		 } else {
			 return (parent ?? presentingViewController)?.ancestor()
		 }
	 }
	
}
