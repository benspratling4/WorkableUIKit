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
	
	
	open override var forFirstBaselineLayout: UIView {
		let labels = allSubviews(ofType: UILabel.self)
		let textFields = allSubviews(ofType: UITextField.self)
		let textViews = allSubviews(ofType: UITextView.self)
		//TODO: all subviews for which forFirstBaselineLayout does not return self
		
		var allTextableViews:[UIView] = labels + textFields + textViews
		let sortedTextableViews = allTextableViews.sorted(by: { $0.frame.origin.y < $1.frame.origin.y })
		if let textView = sortedTextableViews.first {
			return textView
		}
		if #available(iOS 13.0, tvOS 13.0, macCatalyst 13.0, *) {
			let imageViews = allSubviews(ofType: UIImageView.self)
				.filter({ $0.image?.baselineOffsetFromBottom != nil })
				.sorted(by: { $0.frame.origin.y < $1.frame.origin.y })
			if let firstImageView = imageViews.first {
				return firstImageView
			}
		}
		return super.forFirstBaselineLayout
	}
	
	
	open override var forLastBaselineLayout: UIView {
		let labels = allSubviews(ofType: UILabel.self)
		let textFields = allSubviews(ofType: UITextField.self)
		let textViews = allSubviews(ofType: UITextView.self)
		//TODO: all subviews for which forFirstBaselineLayout does not return self
		
		var allTextableViews:[UIView] = labels + textFields + textViews
		let sortedTextableViews = allTextableViews.sorted(by: { $0.frame.origin.y < $1.frame.origin.y })
		if let textView = sortedTextableViews.last {
			return textView
		}
		if #available(iOS 13.0, tvOS 13.0, macCatalyst 13.0, *) {
			let imageViews = allSubviews(ofType: UIImageView.self)
				.filter({ $0.image?.baselineOffsetFromBottom != nil })
				.sorted(by: { $0.frame.origin.y < $1.frame.origin.y })
			if let firstImageView = imageViews.last {
				return firstImageView
			}
		}
		return super.forLastBaselineLayout
	}
	
}
