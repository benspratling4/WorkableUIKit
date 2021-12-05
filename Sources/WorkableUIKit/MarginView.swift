//
//  Margins.swift
//  SingAccordTest
//
//  Created by Ben Spratling on 6/30/19.
//  Copyright © 2019 Ben Spratling. All rights reserved.
//

import Foundation
import UIKit


open class MarginView<Wrapped : UIView> : UIView {
	
	public init(wrapped:Wrapped, insets:NSDirectionalEdgeInsets) {
		self.wrapped = wrapped
		super.init(frame: .zero)
		addSubview(wrapped.forAutoLayout())
		leadingConstraint = wrapped.leadingAnchor == leadingAnchor + insets.leading
		topConstraint = wrapped.topAnchor == topAnchor + insets.top
		
		trailingConstraint = trailingAnchor == wrapped.trailingAnchor + insets.trailing
		bottomConstraint = wrapped.bottomAnchor == bottomAnchor + insets.bottom
	}
	
	///DO NOT CALL
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	public let wrapped:Wrapped
	
	public var leadingConstraint:NSLayoutConstraint?
	public var trailingConstraint:NSLayoutConstraint?
	public var topConstraint:NSLayoutConstraint?
	public var bottomConstraint:NSLayoutConstraint?
	
	open var leadingConstant:CGFloat {
		get {
			return leadingConstraint?.constant ?? 0.0
		}
		set {
			leadingConstraint?.constant = newValue
		}
	}
	
	open var trailingConstant:CGFloat {
		get {
			return trailingConstraint?.constant ?? 0.0
		}
		set {
			trailingConstraint?.constant = newValue
		}
	}
	
	open var topConstant:CGFloat {
		get {
			return topConstraint?.constant ?? 0.0
		}
		set {
			topConstraint?.constant = newValue
		}
	}
	
	open var bottomConstant:CGFloat {
		get {
			return bottomConstraint?.constant ?? 0.0
		}
		set {
			bottomConstraint?.constant = newValue
		}
	}
	
}




extension UIView {
	///Unfortuntely, the current version of Swift can't handle Self as a generic constraint when it is not the entire return type, so the resturn type of this erases the wrapped type
	public func padding(_ insets:NSDirectionalEdgeInsets = .zero)->MarginView<UIView> {
		return MarginView<UIView>(wrapped: self, insets: insets)
	}
	
}
