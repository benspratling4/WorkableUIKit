//
//  ZStack.swift
//  WorkableUIKit
//
//  Created by Ben Spratling on 12/5/21.
//

import Foundation
import UIKit



///functions like similarly to a SwiftUI ZStack
open class ZStack : UIView {
	
	public convenience init(_ views:[UIView]) {
		self.init(views.map({ (.fill, $0) }))
		didInit()
	}
	
	public init(_ views:[(Alignment, UIView)]) {
		self.views = views
		super.init(frame: .zero)
		didInit()
	}
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func didInit() {
		installViews()
	}
	
	open func installViews() {
		views
			.forEach {
				addSubview($0.1.forAutoLayout())
				applyConstriants($0.1, alignment: $0.0)
			}
	}
	
	public var views:[(Alignment, UIView)] = []
	
	open func applyConstriants(_ view:UIView, alignment:Alignment) {
		switch alignment.horizontal {
		case .leading:
			|-view
			trailingAnchor >= view.trailingAnchor + 0.0 | .allButRequired
			
		case .center:
			view.centerXAnchor == centerXAnchor
			leadingAnchor <= view.leadingAnchor + 0.0 | .allButRequired
			trailingAnchor >= view.trailingAnchor + 0.0 | .allButRequired
			
		case .trailing:
			view-|
			view.leadingAnchor >= leadingAnchor + 0.0 | .allButRequired
			
		case .fill:
			|-view~|
		}
		
		switch alignment.vertical {
			
		case .leading: //aka top
			∫-view
			bottomAnchor >= view.bottomAnchor + 0.0 | .allButRequired
			
		case .center:
			view.centerYAnchor == centerYAnchor
			topAnchor <= view.topAnchor + 0.0 | .allButRequired
			bottomAnchor >= view.bottomAnchor + 0.0 | .allButRequired
			
		case .trailing:
			view-∫
			view.topAnchor >= topAnchor + 0.0 | .allButRequired
			
		case .fill:
			∫-view~∫
		}
	}
	
	public enum AxisAlignment : Equatable {
		case leading, center, trailing, fill
		
		public static let top:AxisAlignment = .leading
		public static let bottom:AxisAlignment = .trailing
	}
	
	public struct Alignment : Equatable {
		public var horizontal:AxisAlignment
		public var vertical:AxisAlignment
		
		public init(horizontal:AxisAlignment, vertical:AxisAlignment) {
			self.horizontal = horizontal
			self.vertical = vertical
		}
		
		public static let fill:Alignment = Alignment(horizontal: .fill, vertical: .fill)
		public static let center:Alignment = Alignment(horizontal: .center, vertical: .center)
		
		public static let topCenter:Alignment = Alignment(horizontal: .center, vertical: .top)
		public static let bottomCenter:Alignment = Alignment(horizontal: .center, vertical: .bottom)
		public static let leadingCenter:Alignment = Alignment(horizontal: .leading, vertical: .center)
		public static let trailingCenter:Alignment = Alignment(horizontal: .trailing, vertical: .center)
		
		public static let topLeading:Alignment = Alignment(horizontal: .leading, vertical: .top)
		public static let topTrailing:Alignment = Alignment(horizontal: .trailing, vertical: .top)
		public static let bottomLeading:Alignment = Alignment(horizontal: .leading, vertical: .bottom)
		public static let bottomtrailing:Alignment = Alignment(horizontal: .trailing, vertical: .bottom)
	}
	
}
