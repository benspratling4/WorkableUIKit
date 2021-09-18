//
//  TrackingTapGestureRecognizer.swift
//  SingAccordUI
//
//  Created by Ben Spratling on 12/30/19.
//  Copyright © 2019 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass


open class TrackingTapGestureRecognizer : UITapGestureRecognizer {
	
	public init(target: Any?, action: Selector?, didChangeIsTracking:((_ isTracking:Bool)->())? = nil) {
		self.didChangeIsTracking = didChangeIsTracking
		super.init(target: target, action: action)
	}
	
	public var didChangeIsTracking:((_ isTracking:Bool)->())?
	
	public private(set) var isTracking:Bool = false {
		didSet {
			didChangeIsTracking?(isTracking)
		}
	}
	
	//MARK: - UIKit.UIGestureRecognizerSubclass
	
	open override func reset() {
		super.reset()
		isTracking = false
	}
	
	open override var state: UIGestureRecognizer.State {
		willSet {
			switch newValue {
			case .recognized, .ended, .failed, .cancelled:
				isTracking = false
			default:
				break
			}
		}
	}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		if touches.count > 0, view != nil {
			isTracking = true
		}
		super.touchesBegan(touches, with: event)
	}
	
}
