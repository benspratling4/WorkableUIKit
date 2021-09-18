//
//  BannerViewController.swift
//  CommonUI
//
//  Created by Ben Spratling on 3/7/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit


open class BannerViewController : EmbeddingViewController {
	public func showErrorBanner(text:String) {
		showBannerItem(BannerItem(text: text))
	}
	
	public func showMessageBanner(text:String) {
		showBannerItem(BannerItem(text: text, textColor:.label, bannerColor: .systemBackground))
	}
	
	public func showBannerItem(_ item:BannerItem) {
		bannerItemQueue.append(item)
		if activeBannerView == nil {
			showNext()
		}
		//else, it'll get handled when the the current item leaves
	}
	
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		modalPresentationStyle = .overCurrentContext
	}
	
	private var bannerItemQueue:[BannerItem] = []
	
	private var activeBannerView:BannerView?
	private var currentTimer:Timer?
	
	
	private func showNext() {
		if let newItem = bannerItemQueue.first {
			bannerItemQueue.removeFirst()
			animateInItem(newItem)
		}
	}
	
	private func animateInItem(_ item:BannerItem) {
		let newBannerView = BannerView(item:item).forAutoLayout()
		activeBannerView = newBannerView
		view.addSubview(newBannerView)
		newBannerView.centerXAnchor == view.centerXAnchor
		newBannerView.trailingAnchor <= view.safeAreaLayoutGuide.trailingAnchor - 10.0
		let lowerConstraint = newBannerView.bottomAnchor == view.topAnchor
//		newBannerView.topAnchor == self.view.safeAreaLayoutGuide.topAnchor
		view.layoutIfNeeded()
		UIView.animate(withDuration:0.5, animations: {
			lowerConstraint.isActive = false
			newBannerView.topAnchor == self.view.safeAreaLayoutGuide.topAnchor
			self.view.layoutIfNeeded()
		}, completion: { finished in
			if finished {
				switch item.dismissal {
					case .delay(let interval):
						self.currentTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] (timer) in
							self?.currentTimer = nil
							self?.animateItemOut()
						})
				}
			}
		})
	}
	
	private func animateItemOut() {
		guard let oldView = activeBannerView else { return }
		activeBannerView = nil
		UIView.animate(withDuration:0.5, animations: {
			if let oldTopConstraint = self.view.constraintsInvolving(oldView, attributes: [.top]).first {
				oldTopConstraint.isActive = false
			}
			oldView.bottomAnchor == self.view.topAnchor
			self.view.layoutIfNeeded()
		}, completion: { finished in
			if finished {
				oldView.removeFromSuperview()
			}
		})
		showNext()
	}
}


public struct BannerItem {
	public var text:String
	public var textColor:UIColor
	public var bannerColor:UIColor
	public var dismissal:Dismissal
	public init(text:String, textColor:UIColor = .systemBackground, bannerColor:UIColor = .systemRed, dismissal:Dismissal = .delay()) {
		self.text = text
		self.textColor = textColor
		self.bannerColor = bannerColor
		self.dismissal = dismissal
	}
	
	public enum Dismissal {
		case delay(TimeInterval = 3.0)
	//	case whenTapped((()->())?)
	}
}


open class BannerView : UIView {
	
	public init(item:BannerItem, margin:CGFloat = 10.0) {
		super.init(frame:CGRect(origin: .zero, size: CGSize(width: 320.0, height: 40.0)))
		self.margin = margin
		commonInit()
		label.text = item.text
		label.textColor = item.textColor
		innerBanner.backgroundColor = item.bannerColor
	}
	
	public var margin:CGFloat = 10.0
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	open func commonInit() {
		isUserInteractionEnabled = true
		addSubview(innerBanner)
		|-margin-innerBanner-margin-|
		/-margin/innerBanner/margin-/
	}
	
	
	lazy var innerBanner:UIView = self.newInnerBanner()
	
	func newInnerBanner()->UIView {
		let aView = UIView().forAutoLayout()
		aView.clipsToBounds = true
		aView.layer.cornerRadius = margin
		aView.heightAnchor >= 44.0
		aView.layer.shadowOffset = .zero
		aView.layer.shadowOpacity = 0.3
		aView.layer.shadowRadius = margin
		aView.layer.shadowColor = UIColor.black.cgColor
		
		aView.addSubview(label)
		|-margin-label-margin-|
		/-margin/label/margin-/
		
		return aView
	}
	
	
	lazy var label:UILabel = self.newLabel()
	
	func newLabel()->UILabel {
		let aLabel = UILabel(frame: .zero).forAutoLayout()
		aLabel.backgroundColor = .clear
		aLabel.numberOfLines = 0
		aLabel.lineBreakMode = .byWordWrapping
		aLabel.sizeToFit()
		return aLabel
	}
	
	
}
