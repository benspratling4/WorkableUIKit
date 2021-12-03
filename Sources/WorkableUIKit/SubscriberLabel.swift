//
//  SubscriberLabel.swift
//  
//
//  Created by Ben Spratling on 12/2/21.
//  Copyright © 2021 benspratling.com. All rights reserved.
//

import Foundation
import Combine
import UIKit



extension UILabel {
	///makes it easy to create and finish with a label in just one line
	public convenience init(text:String?, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural) {
		self.init(frame: .zero)
		self.text = text
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
	}
}



open class SubscriberLabel : UILabel {
	
	///You have an @Published var :SomeStruct, and SomeStruct has some String? property you want to update
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, keyPath:KeyPath<ValuePublisher.Output, String?>, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { _ in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newValue in
			self?.processIncomingText(newValue[keyPath: keyPath])
		})
	}
	
	///You have an @Published var :SomeStruct, and SomeStruct has some String property you want to update
	public init<ValuePublisher:Publisher>(binding:ValuePublisher, keyPath:KeyPath<ValuePublisher.Output, String>, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { _ in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newValue in
			self?.processIncomingText(newValue[keyPath: keyPath])
		})
	}
	
	///You have an @Published var :SomeStruct?, and SomeStruct has some String? property you want to update
	public init<ValuePublisher:Publisher, ValueType>(binding:ValuePublisher, keyPath:KeyPath<ValueType, String?>, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) where ValuePublisher.Output == Optional<ValueType> {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { completion in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newValue in
			self?.processIncomingText(newValue?[keyPath: keyPath])
		})
	}
	
	
	///You have an @Published var :SomeStruct?, and SomeStruct has some String property you want to update
	public init<ValuePublisher:Publisher, ValueType>(binding:ValuePublisher, keyPath:KeyPath<ValueType, String>, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) where ValuePublisher.Output == Optional<ValueType> {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { completion in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newValue in
			self?.processIncomingText(newValue?[keyPath: keyPath])
		})
	}
	

	///For Publisher<String?, Error>
	public init<TextPublisher:Publisher>(binding:TextPublisher, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) where TextPublisher.Output == String? {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { _ in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newText in
			self?.processIncomingText(newText)
		})
		
		if let subject = binding as? CurrentValueSubject<String, TextPublisher.Failure> {
			self.text = subject.value
		}
	}
	
	///For Publisher<String, Error>
	public init<TextPublisher:Publisher>(binding:TextPublisher, textColor:UIColor? = nil, font:UIFont? = nil, alignment:NSTextAlignment = .natural, hiding:Hiding? = nil) where TextPublisher.Output == String {
		self.hiding = hiding
		super.init(frame: .zero)
		if let color = textColor {
			self.textColor = color
		}
		if let ft = font {
			self.font = ft
		}
		self.textAlignment = alignment
		textObserving = binding.sink(receiveCompletion: { _ in
			//this space intentionally left blank
		}, receiveValue: { [weak self] newText in
			self?.processIncomingText(newText)
		})
		
		if let subject = binding as? CurrentValueSubject<String, TextPublisher.Failure> {
			self.text = subject.value
		}
	}
	
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private let hiding:Hiding?
	
	func processIncomingText(_ newText:String?) {
		self.text = newText
		guard let hideConditions = hiding else {
			return
		}
		
		switch hideConditions {
		case .nilOrEmpty:
			isHidden = newText?.isEmpty != false
			
		case .when(let condition):
			isHidden = condition(newText)
		}
	}
	
	private var textObserving:AnyCancellable?
	
	///This view can auto hide when the text meets certain requirements
	public enum Hiding {
		///hides the text field when the text is nil or isEmpty
		case nilOrEmpty
		case when((String?)->Bool)
	}
	
}

