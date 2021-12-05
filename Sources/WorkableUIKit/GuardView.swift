//
//  GuardView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/4/21.
//

import Foundation
import Combine
import UIKit


///A view which, like  AssigningWrappingView, observes and assigns values from a publisher to a content view, however, it also has a condition, and will remove the view from itself when the condition is false, and instead insert a zero-size view
open class GuardView<ViewType:UIView, Value> : GuardElseView<ViewType, GuardHiddenView, Value> {
	public init<ValuePublisher:Publisher>(binding: ValuePublisher, condition:@escaping(Value)->(Bool), keyPath: ReferenceWritableKeyPath<ViewType, Value>, content: ViewType) where ValuePublisher.Output == Value {
		super.init(binding: binding, condition: condition, keyPath: keyPath, elseView: GuardHiddenView(), content: content)
	}
	
	public init<ValuePublisher:Publisher>(binding: ValuePublisher, condition:@escaping(Value)->(Bool), keyPath: ReferenceWritableKeyPath<ViewType, Value>, content: ViewType) where Value == Optional<ValuePublisher.Output> {
		super.init(binding: binding, condition: condition, keyPath: keyPath, elseView: GuardHiddenView(), content: content)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


///A view which, like  GuardView, except if your content view should only get non-nil values, and be removed when nil
open class GuardNonNilView<ViewType : UIView, ViewValue> : GuardNonNilElseView<ViewType, GuardHiddenView, Optional<ViewValue>, ViewValue> {
	
	public init<ValuePublisher:Publisher>(binding: ValuePublisher
								   , keyPath: ReferenceWritableKeyPath<ViewType, ViewValue>
								   , content: ViewType)
	where ValuePublisher.Output == Optional<ViewValue> {
		super.init(binding: binding
				   , condition: { $0 }
				   , keyPath: keyPath
				   , elseView: GuardHiddenView()
				   , content: content)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


///A view which, like  AssigningWrappingView, observes and assigns values from a publisher to a content view, however, it also has a condition, and will remove the view from itself when the condition is false, and instead insert an ElseViewType.
open class GuardNonNilElseView<ViewType : UIView, ElseViewType : UIView, Value, ViewValue> : SubscribingWrappingView<UIView, Value> {

	public init<ValuePublisher:Publisher>(binding: ValuePublisher, condition:@escaping(Value)->(ViewValue?), keyPath: ReferenceWritableKeyPath<ViewType, ViewValue>, elseView:ElseViewType, content: ViewType) where ValuePublisher.Output == Value {
		self.ifContent = content
		self.elseContent = elseView
		self.compactMap = condition
		self.innerWrapper = WrappingView<UIView>(content: elseContent)
		self.keyPath = keyPath
		super.init(binding: binding, content: innerWrapper)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//don't call .content any more for type-access to the view which is present when
	public var ifContent:ViewType

	public var elseContent:ElseViewType

	public var compactMap:(Value)->(ViewValue?)
	
	private var innerWrapper:WrappingView<UIView>
	
	public let keyPath:ReferenceWritableKeyPath<ViewType, ViewValue>
	
	open override func didRecieveValue(_ value:Value) {
		super.didRecieveValue(value)
		if let newValue = compactMap(value) {
			ifContent[keyPath: keyPath] = newValue
			innerWrapper.content = ifContent
		}
		else {
			innerWrapper.content = elseContent
		}
	}
	
}


///A view which, like  AssigningWrappingView, observes and assigns values from a publisher to a content view, however, it also has a condition, and will remove the view from itself when the condition is false, and instead insert an ElseViewType.
open class GuardElseView<ViewType : UIView, ElseViewType : UIView, Value> : SubscribingWrappingView<UIView, Value> {

	public init<ValuePublisher:Publisher>(binding: ValuePublisher, condition:@escaping(Value)->(Bool), keyPath: ReferenceWritableKeyPath<ViewType, Value>, elseView:ElseViewType, content: ViewType) where ValuePublisher.Output == Value {
		self.ifContent = content
		self.elseContent = elseView
		self.condition = condition
		self.innerWrapper = WrappingView<UIView>(content: elseContent)
		self.keyPath = keyPath
		super.init(binding: binding, content: innerWrapper)
	}
	
	public init<ValuePublisher:Publisher>(binding: ValuePublisher, condition:@escaping(Value)->(Bool), keyPath: ReferenceWritableKeyPath<ViewType, Value>, elseView:ElseViewType, content: ViewType) where Value == Optional<ValuePublisher.Output> {
		self.ifContent = content
		self.elseContent = elseView
		self.condition = condition
		self.innerWrapper = WrappingView<UIView>(content: elseContent)
		self.keyPath = keyPath
		super.init(binding: binding, content: innerWrapper)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//don't call .content any more for type-access to the view which is present when
	open var ifContent:ViewType

	open var elseContent:ElseViewType

	open var condition:(Value)->(Bool)
	
	private var innerWrapper:WrappingView<UIView>
	
	public let keyPath:ReferenceWritableKeyPath<ViewType, Value>
	
	open override func didRecieveValue(_ value:Value) {
		super.didRecieveValue(value)
		if condition(value) {
			ifContent[keyPath: keyPath] = value
			innerWrapper.content = ifContent
		}
		else {
			innerWrapper.content = elseContent
		}
	}

}


open class GuardHiddenView : UIView {
	
	open override var intrinsicContentSize: CGSize {
		return .zero
	}

}




