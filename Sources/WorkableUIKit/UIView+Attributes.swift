//
//  UIVIew+Attributes.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit


extension UIView {
	
	///this works for most things, like, background color, accessbility identifiers,
	public func setting<Value>(_ keyPath:ReferenceWritableKeyPath<UIView, Value>, _ value:Value)->Self {
		self[keyPath:keyPath] = value
		return self
	}
	
	public func compressionResistance(_ priority:UILayoutPriority, for axis:NSLayoutConstraint.Axis)->Self {
		setContentCompressionResistancePriority(priority, for: axis)
		return self
	}
	
	public func huggingPriority(_ priority:UILayoutPriority, for axis:NSLayoutConstraint.Axis)->Self {
		setContentHuggingPriority(priority, for: axis)
		return self
	}
	
}

