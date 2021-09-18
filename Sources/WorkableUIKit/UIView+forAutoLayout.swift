//
//  UIView+forAutoLayout.swift
//  CommonUI
//
//  Created by Ben Spratling on 10/11/20.
//  Copyright © 2020 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit



extension UIView {
	public func forAutoLayout()->Self {
		translatesAutoresizingMaskIntoConstraints = false
		return self
	}
}
