//
//  Margins.swift
//  SingAccordTest
//
//  Created by Ben Spratling on 6/30/19.
//  Copyright © 2019 Ben Spratling. All rights reserved.
//

import Foundation
import UIKit


public class MarginView<Wrapped : UIView> : UIView {
	
	public init(wrapped:Wrapped, insets:NSDirectionalEdgeInsets) {
		self.wrapped = wrapped
		super.init(frame: .zero)
		addSubview(wrapped)
		|-insets.leading-wrapped-insets.trailing-|
		/-insets.top/wrapped/insets.bottom-/
	}
	
	///DO NOT CALL
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	public let wrapped:Wrapped
	
}


