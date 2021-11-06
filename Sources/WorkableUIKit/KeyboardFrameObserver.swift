//
//  KeyboardFrameObserver.swift
//  
//
//  Created by Ben Spratling on 11/6/21.
//

import Foundation
import UIKit


extension UIView.AnimationOptions {
	public init(curve:UIView.AnimationCurve) {
		switch curve {
		case .easeIn:
			self = .curveEaseIn
		case .easeOut:
			self = .curveEaseOut
		case .easeInOut:
			self = .curveEaseInOut
		case .linear:
			self = .curveLinear
		@unknown default:
			self = .curveEaseInOut
		}
	}
}


open class KeyboardFrameObserver {
	
	open var currentFrame:CGRect = .zero
	
	open var onChange:(_ newFrame:CGRect)->()
	
	public init(onChange:@escaping(_ newFrame:CGRect)->()) {
		self.onChange = onChange
		let center:NotificationCenter = .default
		willShowObject = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
			self?.keyboardWillShow(notification)
		}
		didShowObject = center.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [weak self] (notification) in
			self?.keyboardDidShow(notification)
		}
		willHideObject = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
			self?.keyboardWillHide(notification)
		}
		didHideObject = center.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil) { [weak self] (notification) in
			self?.keyboardDidHide(notification)
		}
		willChangeObject = center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil, using: {[weak self] (notification) in
			self?.keyboardWillUpdate(notification)
		})
		didChangeObject = center.addObserver(forName: UIResponder.keyboardDidChangeFrameNotification, object: nil, queue: nil, using: {[weak self] (notification) in
			self?.keyboardDidUpdate(notification)
		})
	}
	
	open func keyboardWillShow(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func keyboardDidShow(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func keyboardWillHide(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func keyboardDidHide(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func keyboardDidUpdate(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func keyboardWillUpdate(_ notification:Notification) {
		guard let nextFrame:CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		currentFrame = nextFrame
		animate(notification: notification, rect: nextFrame, animations: onChange)
	}
	
	open func animate(notification:Notification, rect:CGRect, animations:@escaping (CGRect)->()) {
		guard let duration:Double = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
			,let curveRawValue:Int = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
			,var curve = UIView.AnimationCurve(rawValue: curveRawValue)
			else {
				animations(rect)
				return
		}
		if curve.rawValue < 0 || curve.rawValue > 3 {
			curve = .easeOut
		}
		UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(curve:curve), animations: { ()->() in
			animations(rect)
		}, completion: nil)
	}
	
	private var willChangeObject:NSObjectProtocol?
	private var didChangeObject:NSObjectProtocol?
	private var willShowObject:NSObjectProtocol?
	private var didShowObject:NSObjectProtocol?
	private var willHideObject:NSObjectProtocol?
	private var didHideObject:NSObjectProtocol?
	
	deinit {
		let center:NotificationCenter = .default
		if let observer = willShowObject {
			center.removeObserver(observer)
		}
		if let observer = didShowObject {
			center.removeObserver(observer)
		}
		if let observer = willHideObject {
			center.removeObserver(observer)
		}
		if let observer = didHideObject {
			center.removeObserver(observer)
		}
		
		if let observer = willChangeObject {
			center.removeObserver(observer)
		}
		
		if let observer = didChangeObject {
			center.removeObserver(observer)
		}
	}
	
	
}
