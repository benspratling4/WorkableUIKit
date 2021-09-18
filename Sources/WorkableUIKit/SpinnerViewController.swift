//
//  SpinnerViewController.swift
//  CommonUI
//
//  Created by Ben Spratling on 3/7/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit


open class SpinnerViewController : UIViewController {
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		//cover the entire prvious view
		modalPresentationStyle = .overFullScreen
		modalTransitionStyle = .crossDissolve
		
		//background should intercept touches
		view.backgroundColor = .init(white: 0.0, alpha: 0.3)
		view.isUserInteractionEnabled = true
		
		//the square
		view.addSubview(square)
		view.centerYAnchor == square.centerYAnchor
		view.centerXAnchor == square.centerXAnchor
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		spinner.startAnimating()
	}
	
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		spinner.stopAnimating()
	}
	
	public lazy var square:UIView = self.newSquare()
	
	open func newSquare()->UIView {
		let aSquare = UIView(frame: .zero)
		aSquare.translatesAutoresizingMaskIntoConstraints = false
		aSquare.backgroundColor = .systemBackground
		aSquare.layer.cornerRadius = 10.0
		aSquare.clipsToBounds = true
		aSquare.widthAnchor == 120.0
		aSquare.heightAnchor == 120.0
		
		aSquare.addSubview(spinner)
		spinner.centerYAnchor == aSquare.centerYAnchor
		spinner.centerXAnchor == aSquare.centerXAnchor
		return aSquare
	}
	
	public lazy var spinner:UIActivityIndicatorView = self.newSpinner()
	
	open func newSpinner()->UIActivityIndicatorView {
		let activity = UIActivityIndicatorView(style: .large)
		activity.translatesAutoresizingMaskIntoConstraints = false
		activity.hidesWhenStopped = true
		return activity
	}
	
}
