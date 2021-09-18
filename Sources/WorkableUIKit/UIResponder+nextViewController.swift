//
//  UIResponder+nextViewController.swift
//  SingAccordUI
//
//  Created by Ben Spratling on 12/29/19.
//  Copyright © 2019 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
	
	public var nextViewControllerResponder:UIViewController? {
		if let selfController = self as? UIViewController {
			return selfController
		}
		return next?.nextViewControllerResponder
	}
}
