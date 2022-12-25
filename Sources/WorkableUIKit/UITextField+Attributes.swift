//
//  UITextField.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit




extension UITextField {
	
	public func settingTextField<Value>(_ keyPath:ReferenceWritableKeyPath<UITextField, Value>, _ value:Value)->Self {
		self[keyPath:keyPath] = value
		return self
	}
	
}
