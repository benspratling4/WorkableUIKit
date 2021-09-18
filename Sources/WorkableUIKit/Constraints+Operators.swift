//
//  Constraints+Operators.swift
//  SpratUIKitLeitmotifs
//
//  Created by Ben Spratling on 5/1/17.
//  Copyright © 2017 benspratling.com. All rights reserved.
//

import Foundation


prefix operator |-

prefix operator |-|-

postfix operator -|

postfix operator -|-|

import UIKit


public struct ConstraintFeature {
	public let item:Any
	public let attribute:NSLayoutConstraint.Attribute
	///only if different from item
	public let view:UIView?
	public init(item:Any, attribute:NSLayoutConstraint.Attribute, view:UIView? = nil) {
		self.item = item
		self.attribute = attribute
		self.view = view
	}
	
	@discardableResult private func install(relation:NSLayoutConstraint.Relation, to constant:CGFloat)->NSLayoutConstraint? {
		guard let lhView:UIView = item as? UIView ?? view else { return nil }
		let constraint:NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: constant)
		lhView.addConstraint(constraint)
		return constraint
	}
	
	@discardableResult public static func ==(lhs:ConstraintFeature, rhs:CGFloat)->NSLayoutConstraint? {
		return lhs.install(relation: .equal, to: rhs)
	}
	
	public static func >=(lhs:ConstraintFeature, rhs:CGFloat) {
		lhs.install(relation: .greaterThanOrEqual, to: rhs)
	}
	
	public static func <=(lhs:ConstraintFeature, rhs:CGFloat) {
		lhs.install(relation: .lessThanOrEqual, to: rhs)
	}
	
	static public func *(lhs:ConstraintFeature, rhs:CGFloat)->ConstraintFactor {
		return ConstraintFactor(feature: lhs, factor: rhs, constant: 0.0)
	}
	
	static public func +(lhs:ConstraintFeature, rhs:CGFloat)->ConstraintFactor {
		return ConstraintFactor(feature: lhs, factor: 1.0, constant: rhs)
	}
	
	static public func -(lhs:ConstraintFeature, rhs:CGFloat)->ConstraintFactor {
		return ConstraintFactor(feature: lhs, factor: 1.0, constant: -rhs)
	}
	
	static public func |(lhs:ConstraintFeature, rhs:UILayoutPriority)->ConstraintFactor {
		return ConstraintFactor(feature: lhs, factor: 1.0, constant: 0.0, priority: rhs)
	}
	
	@discardableResult private func install(relation:NSLayoutConstraint.Relation, to feature:ConstraintFeature)->NSLayoutConstraint? {
		guard let lhView:UIView = item as? UIView ?? view
			,let rhView:UIView = feature.item as? UIView ?? feature.view
			,let parentView:UIView = lhView.shallowestCommonAncestor(with: rhView) else { return nil }
		let constraint:NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: feature.item, attribute: feature.attribute, multiplier: 1.0, constant: 0.0)
		parentView.addConstraint(constraint)
		return constraint
	}
	
	@discardableResult public static func ==(lhs:ConstraintFeature, rhs:ConstraintFeature)->NSLayoutConstraint? {
		return lhs.install(relation: .equal, to: rhs)
	}
	
	@discardableResult public static func <=(lhs:ConstraintFeature, rhs:ConstraintFeature)->NSLayoutConstraint? {
		return lhs.install(relation: .lessThanOrEqual, to: rhs)
	}
	
	@discardableResult public static func >=(lhs:ConstraintFeature, rhs:ConstraintFeature)->NSLayoutConstraint? {
		return lhs.install(relation: .greaterThanOrEqual, to: rhs)
	}
	
	@discardableResult private func install(relation:NSLayoutConstraint.Relation, to factor:ConstraintFactor)->NSLayoutConstraint? {
		guard let lhView:UIView = item as? UIView ?? view
			,let rhView:UIView = factor.feature.item as? UIView ?? factor.feature.view
			,let parentView:UIView = lhView.shallowestCommonAncestor(with: rhView) else { return nil }
		let constraint:NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: factor.feature.item, attribute: factor.feature.attribute, multiplier: factor.factor, constant: factor.constant)
		constraint.priority = factor.priority
		parentView.addConstraint(constraint)
		return constraint
	}
	
	@discardableResult public static func ==(lhs:ConstraintFeature, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .equal, to: rhs)
	}
	
	@discardableResult public static func <=(lhs:ConstraintFeature, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .lessThanOrEqual, to: rhs)
	}
	
	@discardableResult public static func >=(lhs:ConstraintFeature, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .greaterThanOrEqual, to: rhs)
	}
	
	
	
}


public struct ConstraintFactor {
	public let feature:ConstraintFeature
	public let factor:CGFloat
	public let constant:CGFloat
	
	public let priority:UILayoutPriority
	
	public init(feature:ConstraintFeature, factor:CGFloat = 1.0, constant:CGFloat = 0.0, priority:UILayoutPriority = UILayoutPriority.required) {
		self.feature = feature
		self.factor = factor
		self.constant = constant
		self.priority = priority
	}
	
	public static func +(lhs:ConstraintFactor, rhs:CGFloat)->ConstraintFactor {
		return ConstraintFactor(feature: lhs.feature, factor: lhs.factor, constant: rhs)
	}
	
	public static func -(lhs:ConstraintFactor, rhs:CGFloat)->ConstraintFactor {
		return ConstraintFactor(feature: lhs.feature, factor: lhs.factor, constant: -rhs)
	}
	
	public static func |(lhs:ConstraintFactor, rhs:UILayoutPriority)->ConstraintFactor {
		return ConstraintFactor(feature: lhs.feature, factor: lhs.factor, constant: lhs.constant, priority: rhs)
	}
	
	@discardableResult private func install(relation:NSLayoutConstraint.Relation, to factor:ConstraintFactor)->NSLayoutConstraint? {
		guard let lhView:UIView = feature.item as? UIView ?? feature.view
			,let rhView:UIView = factor.feature.item as? UIView ?? factor.feature.view
			,let parentView:UIView = lhView.shallowestCommonAncestor(with: rhView) else { return nil }
		let constraint:NSLayoutConstraint = NSLayoutConstraint(item: feature.item, attribute: feature.attribute, relatedBy: relation, toItem: factor.feature.item, attribute: factor.feature.attribute, multiplier: factor.factor, constant: factor.constant)
		constraint.priority = factor.priority
		parentView.addConstraint(constraint)
		return constraint
	}
	
	@discardableResult public static func ==(lhs:ConstraintFactor, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .equal, to: rhs)
	}
	
	@discardableResult public static func <=(lhs:ConstraintFactor, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .lessThanOrEqual, to: rhs)
	}
	
	@discardableResult public static func >=(lhs:ConstraintFactor, rhs:ConstraintFactor)->NSLayoutConstraint? {
		return lhs.install(relation: .greaterThanOrEqual, to: rhs)
	}
	
	@discardableResult private func install(relation:NSLayoutConstraint.Relation, to constant:CGFloat)->NSLayoutConstraint? {
		guard let lhView:UIView = feature.item as? UIView ?? feature.view else { return nil }
		let constraint:NSLayoutConstraint = NSLayoutConstraint(item: lhView, attribute: feature.attribute, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: constant)
		constraint.priority = priority
		lhView.addConstraint(constraint)
		return constraint
	}
	
}


extension UIView {
	
	public var bottomFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .bottom)
	}
	
	public var topFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .top)
	}
	
	public var leadingFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .leading)
	}
	
	public var trailingFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .trailing)
	}
	
	public var centerXFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .centerX)
	}
	
	public var centerYFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .centerY)
	}
	
	public var widthFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .width)
	}
	
	public var heightFeature:ConstraintFeature {
		return ConstraintFeature(item: self, attribute: .height)
	}
	
	public func shallowestCommonAncestor(with otherView:UIView)->UIView? {
		var view:UIView? = self
		repeat {
			guard let aSuperView = view else { return nil }
			if otherView.isDescendant(of: aSuperView) {
				return aSuperView
			}
			view = aSuperView.superview
		} while view != nil
		return view
	}
	/*
	@available(iOS 11.0, *)
	public var topSafeFeature:ConstraintFeature {
		return ConstraintFeature(item: safeAreaLayoutGuide.topAnchor, attribute: .top)
	}
	
	@available(iOS 11.0, *)
	public var bottomSafeFeature:ConstraintFeature {
		return ConstraintFeature(item: safeAreaLayoutGuide.bottomAnchor, attribute: .top)
	}
	*/
}

/*
extension NSViewController {
	
	public var topGuideFeature:ConstraintFeature {
		return ConstraintFeature(item: topLayoutGuide, attribute: .bottom, view: view)
	}
	
	public var bottomGuideFeature:ConstraintFeature {
		return ConstraintFeature(item: bottomLayoutGuide, attribute: .top, view: view)
	}
}
*/




