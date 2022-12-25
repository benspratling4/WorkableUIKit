//
//  UIImageView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit



extension UIImageView {
	
	public func settingImageView<Value>(_ keyPath:ReferenceWritableKeyPath<UIImageView, Value>, _ value:Value)->Self {
		self[keyPath:keyPath] = value
		return self
	}
	
}
