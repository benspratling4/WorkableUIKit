//
//  UILayoutPriority+Operatorrs.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit


extension UILayoutPriority {
	
	public static func +(lhs:UILayoutPriority, rhs:Float)->UILayoutPriority {
		let newRaw:Float = lhs.rawValue + rhs
		return UILayoutPriority(newRaw)
	}
	
	public static func -(lhs:UILayoutPriority, rhs:Float)->UILayoutPriority {
		let newRaw:Float = lhs.rawValue - rhs
		return UILayoutPriority(newRaw)
	}
	
}
