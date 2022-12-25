//
//  SizePlaceholderView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit



open class SizePlaceholderView : UIView {
	
	public init(sizeMode:Mode) {
		self.sizeMode = sizeMode
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		didInit()
	}
	
	open func didInit() {
		setUpSizeConstraints()
	}
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func setUpSizeConstraints() {
		switch sizeMode {
		case .size(let size):
			let widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
			widthConstraint.priority = .required - 2.0
			widthConstraint.isActive = true
			
			let heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
			heightConstraint.priority = .required - 2.0
			heightConstraint.isActive = true
			
		case .aspectRatio(let ratio):
			let ratioConstraint = widthAnchor == heightAnchor * ratio
			ratioConstraint.priority = .required - 2.0
			
		}
	}
	
	
	public let sizeMode:Mode
	
	public enum Mode {
		case size(CGSize)
		
		///width divided by height
		case aspectRatio(CGFloat)
	}
	
}
