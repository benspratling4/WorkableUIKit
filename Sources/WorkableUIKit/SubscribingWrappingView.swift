//
//  SubscribingWrappingView.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/4/21.
//

import Foundation
import Combine
import UIKit


///Subscribes to a publisher of a value and calls didRecieveValue() when it gets a value
open class SubscribingWrappingView<ViewType:UIView, Value> : WrappingView<ViewType>  {
	
	///for a publisher of the same value of the view's value
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, content:ViewType) where ValuePublisher.Output == Value {
		super.init(content: content)
		valueObserver = binding.sink(receiveCompletion: { completion in
			//ignore?
		}, receiveValue: { [weak self] newValue in
			self?.didRecieveValue(newValue)
		})
	}
	
	///for a publisher of a value which the view takes as an optional
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, content:ViewType) where Value == Optional<ValuePublisher.Output>  {
		super.init(content: content)
		valueObserver = binding.sink(receiveCompletion: { completion in
			//ignore?
		}, receiveValue: { [weak self] newValue in
			self?.didRecieveValue(newValue)
		})
	}
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var valueObserver:AnyCancellable?
	
	///Override me
	open func didRecieveValue(_ value:Value) {
		
	}
	
}


///in addition to subscribing for the value, it also sets the value on a property of the content view.
open class AssigningWrappingView<ViewType:UIView, Value> : SubscribingWrappingView<ViewType, Value> {
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, keyPath:ReferenceWritableKeyPath<ViewType, Value>, content:ViewType) where ValuePublisher.Output == Value {
		self.keyPath = keyPath
		super.init(binding:binding, content: content)
	}
	
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, keyPath:ReferenceWritableKeyPath<ViewType, Value>, content:ViewType) where Value == Optional<ValuePublisher.Output> {
		self.keyPath = keyPath
		super.init(binding:binding, content: content)
	}
	
	@available(*, deprecated, message: "DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public let keyPath:ReferenceWritableKeyPath<ViewType, Value>
	
	open override func didRecieveValue(_ value:Value) {
		super.didRecieveValue(value)
		content[keyPath: keyPath] = value
	}
	
}
