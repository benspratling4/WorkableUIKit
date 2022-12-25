//
//  TappableButton.swift
//  SingAccordUI
//
//  Created by Ben Spratling on 12/19/19.
//  Copyright © 2019 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit


///draws a layer over the button to show it's being pressed
open class DimmingButton : UIView {
	
	public init(action:(()->())? = nil) {
		self.action = action
		super.init(frame: .zero)
		commonInit()
	}
	
	public convenience init(action:(()->())? = nil, content:UIView) {
		self.init(action: action)
		addSubview(content)
		|-content-|
		∫-content-∫
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	open func commonInit() {
		accessibilityTraits = .button
		insertSubview(overView, at: 0)
		∫-overView-∫
		|-overView-|
		isUserInteractionEnabled = true
		addGestureRecognizer(tapRecognizer)
	}
	
	///overidden so that everything goes below overView
	open override func addSubview(_ view: UIView) {
		super.insertSubview(view, belowSubview: overView)
	}
	
	public lazy var overView:UIView = self.newOverView()
	
	open func newOverView()->UIView {
		let view = UIView(frame: .zero)
		view.backgroundColor = dimmingColor
		view.alpha = 0.0
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		return view
	}
	
	public var dimmingColor:UIColor = .black {
		didSet {
			overView.backgroundColor = dimmingColor
		}
	}
	
	
	public lazy var tapRecognizer:UIGestureRecognizer = self.newTapRecognizer()
	
	open func newTapRecognizer()->UIGestureRecognizer {
		let recognizer = TrackingTapGestureRecognizer(target: self, action: #selector(DimmingButton.userDidTap), didChangeIsTracking:{ [weak self] isTracking in
			self?.trackingChanged(isTracking)
		})
		return recognizer
	}
	
	public var action:(()->())?
	
	
	@objc open func userDidTap(_ recognizer:UIGestureRecognizer) {
		action?()
	}
	
	
	func trackingChanged(_ isTracking:Bool) {
		if isTracking {
			overView.alpha = 0.2
		} else {
			overView.alpha = 0.0
		}
	}
	
	
}
