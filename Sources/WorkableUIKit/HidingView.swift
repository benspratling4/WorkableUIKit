//
//  HidingView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/4/21.
//

import Swift
import Foundation
import Combine
import UIKit


///In addition to subscribing for the value, it will hide when the value meets conditions 
open class HidingView<ViewType:UIView, Value> : SubscribingWrappingView<ViewType, Value> {
	
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, content:ViewType,  hiding:Hiding<Value> = .nilOrEmpty) where ValuePublisher.Output == Value  {
		self.hiding = hiding
		super.init(binding: binding, content: content)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open var hiding:Hiding<Value>
	
	open override func didRecieveValue(_ value: Value) {
		super.didRecieveValue(value)
		updateHiding(value)
	}
	
	open func updateHiding(_ value:Value) {
		switch hiding {
		case .when(let condition):
			isHidden = condition(value)
			
		case .none:
			if let nillable = value as? ComparableToNil {
				isHidden = nillable.equalsNil()
			}
			
		case .nonNil:
			if let nillable = value as? ComparableToNil {
				isHidden = !nillable.equalsNil()
			}
			
		case .empty:
			if let emptiableValue = value as? Emptiable {
				isHidden = emptiableValue.isEmpty
			}
			
		case .nonEmpty:
			if let emptiableValue = value as? Emptiable {
				isHidden = !emptiableValue.isEmpty
			}
			
		case .nilOrEmpty:
			if let emptiableValue = value as? Emptiable {
				isHidden = emptiableValue.isEmpty
			}
			else if let nillable = value as? ComparableToNil {
				isHidden = nillable.equalsNil()
			}
			
		case .notNilNorEmpty:
			if let emptiableValue = value as? Emptiable {
				isHidden = !emptiableValue.isEmpty
			}
			else if let nillable = value as? ComparableToNil {
				isHidden = !nillable.equalsNil()
			}
		}
	}
	
	//This view can auto hide when the text meets certain requirements
	public enum Hiding<Value> {
		///a.k.a. "nil"
		case none
		
		///hides the text field when the text is nil or isEmpty
		case nilOrEmpty
		
		case empty
		
		case nonNil
		
		case nonEmpty
		
		case notNilNorEmpty
		
		///You define your own method which returns true when the view should be hidden
		case when((Value?)->Bool)
	}
}


public protocol Emptiable {
	var isEmpty:Bool { get }
}

extension String : Emptiable { }
extension Array : Emptiable { }
extension Set : Emptiable { }
//What else can be 'isEmpty`


public protocol ComparableToNil {
	func equalsNil()->Bool
}

extension Optional : ComparableToNil {
	public func equalsNil()->Bool {
		return self == nil
	}
}
