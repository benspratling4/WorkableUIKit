//
//  CutOutShadeView.swift
//  
//
//  Created by Ben Spratling on 3/1/23.
//

import Foundation
import UIKit
import CoreGraphics



///a view which draws a shade except in a given rect
open class CutOutShadeView : UIView {
	
	public init(shadeColor:UIColor = .black
		 ,shape:CutOutShape = .capsule
		 ,cutOutRect:CGRect = .zero
	) {
		self.shadeColor = shadeColor
		self.shape = shape
		self.cutOutRect = cutOutRect
		super.init(frame: .zero)
		backgroundColor = .clear
	}
	
	///It should be able to create a CGColor
	open var shadeColor:UIColor {
		didSet {
			setNeedsDisplay()
		}
	}
	
	open var shape:CutOutShape {
		didSet {
			setNeedsDisplay()
		}
	}
	
	open var cutOutRect:CGRect {
		didSet {
			if cutOutRect != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	///the alpha applied to the color
	open var shadeAlpha:CGFloat = 0.7 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	///the distance outside the shape of the cutout shape at which the shade color is drawn
	open var cutOutOutset:CGFloat = 2.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	public enum CutOutShape {
		case rect
		case ellipse
		case roundedRect(cornerRadius:CGFloat)
		
		///semi-circles cap the shorter-length edges
		case capsule
	}
	
	
	//MARK: - UIView overrides
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
			setNeedsDisplay()
		}
	}
	
	open override var bounds: CGRect {
		didSet {
			if bounds != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	open override var frame: CGRect {
		didSet {
			if frame != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	open override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		let outSetCutOut = cutOutRect.inset(by: UIEdgeInsets(top: -cutOutOutset, left: -cutOutOutset, bottom: -cutOutOutset, right: -cutOutOutset))
		let cutOutPath:CGPath
		switch shape {
		case .rect:
			cutOutPath = CGPath(rect: outSetCutOut, transform: nil)
		case .ellipse:
			cutOutPath = CGPath(ellipseIn: outSetCutOut, transform: nil)
		case .roundedRect(let cornerRadius):
			cutOutPath = CGPath(roundedRect: outSetCutOut
								,cornerWidth: cornerRadius+cutOutOutset
								,cornerHeight: cornerRadius+cutOutOutset
								,transform: nil)
		case .capsule:
			let cornerRadius = min(outSetCutOut.width, outSetCutOut.height) / 2.0
			cutOutPath = CGPath(roundedRect: outSetCutOut, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
		}
		let finalpath = CGMutablePath()
		finalpath.addRect(frame)
		finalpath.closeSubpath()
		finalpath.addPath(cutOutPath)
		finalpath.closeSubpath()
		context.addPath(finalpath)
		context.setFillColor(shadeColor.withAlphaComponent(shadeAlpha).cgColor)
		context.fillPath(using: .evenOdd)
	}
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
