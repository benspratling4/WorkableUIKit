//
//  DirectionalPanGestureRecognizer.swift
//  CommonUI
//
//  Created by Ben Spratling on 11/26/20.
//  Copyright © 2020 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit


public class DirectionalPanGestureRecognizer : UIPanGestureRecognizer, UIGestureRecognizerDelegate {
	
	public enum Direction {
		case horizontal, vertical
	}
	
	public var direction:Direction
	
	public init(direction:Direction, target:Any?, action:Selector?) {
		self.direction = direction
		super.init(target: target, action: action)
		self.delegate = self
	}
	
	
	//MARK: - UIGestureRecognizerDelegate
	
	public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let offset = self.translation(in: self.view)
		//put in the right range
		let area = abs(abs(atan2(offset.y, offset.x))/CGFloat.pi - 0.5)
		//horizontal things are like 0.4-0.5
		//vertical things are like 0.0-0.1
		switch direction {
			case .horizontal:
				return area > 0.42
			case .vertical:
				return area < 0.08
		}
	}
	
}


public class ClosureDirectionalPanGestureRecognizer<Controller:AnyObject> : DirectionalPanGestureRecognizer {
	public init(direction:Direction, controller:Controller, action:@escaping(Controller, ClosureDirectionalPanGestureRecognizer<Controller>)->())  {
		self.controller = controller
		self.callback = action
		super.init(direction:direction, target:nil, action: nil)
		addTarget(self, action: #selector(ClosureDirectionalPanGestureRecognizer<Controller>.actionCallBack))
	}
	
	private weak var controller:Controller?
	
	private var callback:(Controller, ClosureDirectionalPanGestureRecognizer<Controller>)->()
	
	@objc func actionCallBack(_ recognizer:UIGestureRecognizer) {
		guard let control = controller else { return }
		self.callback(control, self)
	}
}
