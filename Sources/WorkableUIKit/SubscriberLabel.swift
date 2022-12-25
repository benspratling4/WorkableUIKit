//
//  AutoLabel.swift
//  AutoLabel
//
//  Created by Ben Spratling on 12/2/21.
//

import Foundation
import Combine
import UIKit


public typealias SubscriberLabel = AssigningWrappingView<UILabel, String?>

extension SubscriberLabel {
	
	public convenience init<ValuePublisher:Publisher>(_ binding:ValuePublisher, label:(UILabel)->(UILabel) = { $0 }) where ValuePublisher.Output == String? {
		let uiLabel = label(UILabel())
		self.init(binding: binding, keyPath: \.text, content: uiLabel)
	}
	
	public convenience init<ValuePublisher:Publisher>(_ binding:ValuePublisher, label:(UILabel)->(UILabel) = { $0 }) where ValuePublisher.Output == String {
		let uiLabel = label(UILabel())
		self.init(binding: binding, keyPath: \.text, content: uiLabel)
	}
	
}
