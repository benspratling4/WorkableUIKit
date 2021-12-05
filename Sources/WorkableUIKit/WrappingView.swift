//
//  WrappingView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/3/21.
//

import Foundation
import Combine
import UIKit


///The base class for all these other composable views
open class WrappingView<ViewType:UIView> : UIView {
	
	public init(content:ViewType) {
		self.content = content
		super.init(frame: .zero)
		didInit()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var content:ViewType {
		didSet {
			guard oldValue !== content else { return }
			oldValue.removeFromSuperview()
			installContentView()
		}
	}
	
	open func didInit() {
		installContentView()
	}
	
	open func installContentView() {
		content.translatesAutoresizingMaskIntoConstraints = false
		addSubview(content)
		setUpContentLayoutConstraints(wrapped: content)
	}
	
	open func setUpContentLayoutConstraints(wrapped:ViewType) {
		|-wrapped-|
		/-wrapped-/
	}
	
}
