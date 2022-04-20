//
//  NSLayoutAnchor+Operators.swift
//  CommonUI
//
//  Created by Ben Spratling on 11/1/20.
//  Copyright © 2020 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit

public typealias LayoutPriority = UILayoutPriority

/**
The purpose is to turn this:

view.addConstraint(NSLayoutConstraint(item:secondView, attribute:.leading, relatedBy: .equal, toItem:view, attribute:.leading, multiplier:1.0, factor:20.0))

into this:

secondView.leadingAnchor == view.leadingAnchor + 20.0

improving readability, thus lowering the probability of a bug

At this time, both + and - are supported in the constant.  Both imply a multiplier of 1.0

Constant offsets must happen after multipliers, i.e.

secondView.widthAnchor == view.widthAnchor * 0.5 + 20.0

is correct,

secondView.widthAnchor == view.widthAnchor + 20.0 * 0.5

is not.


Set priorities on the constraints with a  | operator followed by a layout priority.  The layout priorities must be correctly typed for your GUIKit

secondView.leadingEdge == view.leadingEdge + 20.0 | .defaultLow

For special cases in which you wish to stop the system from deleting your constraints when they are temporarily not meetable , for instance due to animating the insertion into a StackView, you should use the .allButRequired priority which is .required -1.0

secondView.leadingEdge == view.leadingEdge + 20.0 | .allButRequired


Anchors may be pinned to each other without factor, which implies multiplier 1.0, constant 0.0

secondView.leadingEdge == view.leadingEdge

Heights & widths may be set to pure constant values.

secondView.widthAnchor == 100.0

and multiplied by each other

secondView.heightAnchor == secondView.widthAnchor * 0.5625


Unlike the previous non-anchor based methods, the anchor-based methods support safe edges on iOS automatically with no view controller reference

secondView.topAnchor == view.safeAreaLayoutGuide.topAnchor


Inequalities are supported as well.

secondView.leadingEdge <= view.leadingEdge - 20.0

Prevents a view from extending past the


The equality and inequality operators return an NSLayoutConstraint, allowing you to capture the constraint added by the operator and change its priority.  The catch is that constraints are already added by the time the operator returns, so add low-priority operators first.

if let constraint = secondView.widthEdge == view.widthEdge {
	constraint.priority = 750
}

secondView.trailingEdge <= view.trailingEdge - 20.0
*/


///Anchor must == AnchorType, but that is not expressible in Swift
public struct AnchorFactor<Anchor, AnchorType> where Anchor : NSLayoutAnchor<AnchorType> {
	
	public var anchor:Anchor
	public var factor:CGFloat
	public var constant:CGFloat
	
	public var priority:LayoutPriority
	
	public init(anchor:Anchor, factor:CGFloat = 1.0, constant:CGFloat = 0.0, priority:LayoutPriority = .required) {
		self.anchor = anchor
		self.factor = factor
		self.constant = constant
		self.priority = priority
	}
	/*	//multipliers for non-width / height do not seem to be supported in anchors
	public static func *(lhs:AnchorFactor, rhs:CGFloat)->AnchorFactor {
	return AnchorFactor(anchor: lhs.anchor, factor: rhs, constant: lhs.constant, priority: lhs.priority)
	}*/
	
	public static func +(lhs:AnchorFactor, rhs:CGFloat)->AnchorFactor {
		return AnchorFactor(anchor: lhs.anchor, factor: lhs.factor, constant: rhs, priority: lhs.priority)
	}
	
	public static func -(lhs:AnchorFactor, rhs:CGFloat)->AnchorFactor {
		return AnchorFactor(anchor: lhs.anchor, factor: lhs.factor, constant: -rhs, priority: lhs.priority)
	}
	
	public static func |(lhs:AnchorFactor, rhs:LayoutPriority)->AnchorFactor {
		return AnchorFactor(anchor: lhs.anchor, factor: lhs.factor, constant: lhs.constant, priority: rhs)
	}
	
}

//so here are 3 convenience typealiases
public typealias AnchorXFactor = AnchorFactor<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>
public typealias AnchorYFactor = AnchorFactor<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>
public typealias AnchorDimensionFactor = AnchorFactor<NSLayoutDimension, NSLayoutDimension>


extension NSLayoutDimension {
	@discardableResult public static func ==(lhs:NSLayoutDimension, rhs:CGFloat)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(equalToConstant: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func ==(lhs:NSLayoutDimension, rhs:NSLayoutDimension)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(equalTo: rhs, multiplier: 1.0)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func ==(lhs:NSLayoutDimension, rhs:AnchorDimensionFactor)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.factor)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutDimension, rhs:CGFloat)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutDimension, rhs:AnchorDimensionFactor)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.factor)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutDimension, rhs:CGFloat)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(greaterThanOrEqualToConstant: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutDimension, rhs:AnchorDimensionFactor)->NSLayoutConstraint {
		let constraint:NSLayoutConstraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.factor)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	public static func *(lhs:NSLayoutDimension, rhs:CGFloat)->AnchorDimensionFactor {
		return AnchorDimensionFactor(anchor: lhs, factor: rhs)
	}
	
	public static func +(lhs:NSLayoutDimension, rhs:CGFloat)->AnchorDimensionFactor {
		return AnchorDimensionFactor(anchor: lhs, factor: 1.0, constant: rhs, priority: .required)
	}
	
	public static func -(lhs:NSLayoutDimension, rhs:CGFloat)->AnchorDimensionFactor {
		return AnchorDimensionFactor(anchor: lhs, factor: 1.0, constant: -rhs, priority: .required)
	}
	
	public static func |(lhs:NSLayoutDimension, rhs:LayoutPriority)->AnchorDimensionFactor {
		return AnchorDimensionFactor(anchor: lhs, factor: 1.0, constant:0.0, priority:rhs)
	}
	
}


extension NSLayoutXAxisAnchor {
	
	//MARK: - Creating AnchorFactor
	
	public static func +(lhs:NSLayoutXAxisAnchor, rhs:CGFloat)->AnchorXFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant: rhs, priority: .required)
	}
	
	public static func -(lhs:NSLayoutXAxisAnchor, rhs:CGFloat)->AnchorXFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant: -rhs, priority: .required)
	}
	
	public static func |(lhs:NSLayoutXAxisAnchor, rhs:LayoutPriority)->AnchorXFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant:0.0, priority: rhs)
	}
	
	
	//MARK: - Setting constraints
	
	@discardableResult public static func ==(lhs:NSLayoutXAxisAnchor, rhs:NSLayoutXAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(equalTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutXAxisAnchor, rhs:NSLayoutXAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(lessThanOrEqualTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutXAxisAnchor, rhs:NSLayoutXAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(greaterThanOrEqualTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func ==(lhs:NSLayoutXAxisAnchor, rhs:AnchorXFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutXAxisAnchor, rhs:AnchorXFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutXAxisAnchor, rhs:AnchorXFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
}


extension NSLayoutYAxisAnchor {
	
	//MARK: - Creating AnchorFactor
	
	public static func +(lhs:NSLayoutYAxisAnchor, rhs:CGFloat)->AnchorYFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant: rhs, priority: .required)
	}
	
	public static func -(lhs:NSLayoutYAxisAnchor, rhs:CGFloat)->AnchorYFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant: -rhs, priority: .required)
	}
	
	public static func |(lhs:NSLayoutYAxisAnchor, rhs:LayoutPriority)->AnchorYFactor {
		return AnchorFactor(anchor: lhs, factor: 1.0, constant:0.0, priority: rhs)
	}
	
	
	//MARK: - Setting constraints
	
	@discardableResult public static func ==(lhs:NSLayoutYAxisAnchor, rhs:NSLayoutYAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(equalTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutYAxisAnchor, rhs:NSLayoutYAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(lessThanOrEqualTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutYAxisAnchor, rhs:NSLayoutYAxisAnchor)->NSLayoutConstraint {
		let constraint = lhs.constraint(greaterThanOrEqualTo: rhs)
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func ==(lhs:NSLayoutYAxisAnchor, rhs:AnchorYFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func <=(lhs:NSLayoutYAxisAnchor, rhs:AnchorYFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
	@discardableResult public static func >=(lhs:NSLayoutYAxisAnchor, rhs:AnchorYFactor)->NSLayoutConstraint {
		let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
		constraint.priority = rhs.priority
		constraint.isActive = true
		return constraint
	}
	
}

