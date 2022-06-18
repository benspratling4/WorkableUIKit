//
//  ScrollingStackViewController.swift
//  SingAccordTest
//
//  Created by Ben Spratling on 6/30/19.
//  Copyright © 2019 Ben Spratling. All rights reserved.
//

import Foundation
import UIKit


///vertically scrolls the contents
open class ScrollingStackViewController : UIViewController {
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(scrollView)
		|-scrollView-|
		∫-scrollView
		
		if #available(iOS 15.0, *) {
			scrollView.bottomAnchor == view.keyboardLayoutGuide.topAnchor
		}
		else {
			scrollView.bottomAnchor == view.bottomAnchor
			_ = keyboardObserver	//force lazy init
		}
		
		view.addConstraint(stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor))
	}
	
	
	open lazy var scrollView:UIScrollView = self.newScrollView()
	
	open func newScrollView()->UIScrollView {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollableBackingView)
		|-scrollableBackingView-|
		∫-scrollableBackingView-∫
		view.keyboardDismissMode = .interactive
		return view
	}
	
	///to set a background color of the scrollable area (but not the non-scrollable area) set it on this view
	open lazy var scrollableBackingView:UIView = self.newScrollableBackingView()
	
	open func newScrollableBackingView()->UIView {
		let aView = UIView()
		aView.translatesAutoresizingMaskIntoConstraints = false
		aView.addSubview(stackView)
		|-|-stackView-|-|
		∫-∫-stackView-∫-∫
		return aView
	}
	
	
	open lazy var stackView:UIStackView = self.newStackView()
	
	open func newStackView()->UIStackView {
		let stack = UIStackView(arrangedSubviews: [])
		stack.axis = .vertical
		stack.alignment = .fill
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.backgroundColor = .clear
		return stack
	}
	
	lazy var keyboardObserver:KeyboardFrameObserver = {
		return KeyboardFrameObserver { [weak self] newFrame in
			guard let sSelf = self else { return }
			let keyboardFrameInViewCoordinates:CGRect = sSelf.view.convert(newFrame, from: nil)
			let bottomInset:CGFloat = sSelf.view.bounds.size.height - keyboardFrameInViewCoordinates.origin.y
			var insets:UIEdgeInsets = sSelf.scrollView.contentInset
			insets.bottom = bottomInset
			sSelf.scrollView.contentInset = insets
		}
	}()
	
}

