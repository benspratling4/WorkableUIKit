//
//  UILabel+attributes init.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/4/21.
//

import Foundation
import UIKit


extension UILabel {
	
	public func settingLabel<Value>(_ keyPath:ReferenceWritableKeyPath<UILabel, Value>, _ value:Value)->Self {
		self[keyPath:keyPath] = value
		return self
	}
	
}

