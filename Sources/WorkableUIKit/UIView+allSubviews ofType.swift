//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 12/25/22.
//

import Foundation
import UIKit

extension UIView {
	
	public func allSubviews<SubView:UIView>(ofType subviewType:SubView.Type)->[SubView] {
		var collectedSubViews:[SubView] = []
		if let selfSubview = self as? SubView {
			collectedSubViews.append(selfSubview)
		}
		for aSubview in subviews {
			collectedSubViews.append(contentsOf: aSubview.allSubviews(ofType: subviewType))
		}
		return collectedSubViews
	}
	
}
