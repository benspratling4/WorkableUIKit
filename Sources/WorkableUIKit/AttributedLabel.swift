//
//  AttributedLabel.swift
//  
//
//  Created by Ben Spratling on 11/12/21.
//

import Foundation
import UIKit
import CoreText
import CoreGraphicsExtensions

/**
 Unlike UILabel, this can give you the index in the string that you tapped, or the attributes and effective range of that.
 There's also a convenience method to return the closest link, and a highlight property to enable special coloring of background ranges.
 */
open class AttributedLabel : UIView {
	
	//MARK: - methods you'll actually use
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		didInit()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		didInit()
	}
	
	public var attributedText:NSAttributedString = NSAttributedString() {
		didSet {
			highlight = nil
			accessibilityValue = attributedText.string
			framesetter = CTFramesetterCreateWithAttributedString(attributedText)
			preferredMaxLayoutWidth = systemLayoutSizeFitting(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
		}
	}
	
	//returns an NSString index, not a String offset
	func stringIndex(at point:CGPoint, distance:CGFloat = 0.0)->Int? {
		guard let textFrame = ctFrame else { return nil }
		let pointInCTFrameCoords = CGPoint(x: point.x, y: bounds.size.height - point.y)
		let lines:[CTLine] = CTFrameGetLines(textFrame) as [AnyObject] as! [CTLine]
		var origins:[CGPoint] = [CGPoint](repeating: .zero, count: lines.count)
		CTFrameGetLineOrigins(textFrame, CFRange(location: 0, length: lines.count), &origins)
		let distanceAndIndexes:[(CGFloat, Int)] = lines
			.enumerated()
			.compactMap({ index, line in
				let origin = origins[index]
				var lineRectInFrameCoords = CTLineGetImageBounds(line, nil)
				lineRectInFrameCoords.origin = lineRectInFrameCoords.origin + origin
				let rectDistance = lineRectInFrameCoords.distance(to: pointInCTFrameCoords)
				guard rectDistance <= distance else { return nil }
				let closePoint = lineRectInFrameCoords.pointClosest(to:pointInCTFrameCoords)
				let closePointInLineCoords:CGPoint = closePoint - origin
				let charIndex = CTLineGetStringIndexForPosition(line, closePointInLineCoords)
				guard charIndex != kCFNotFound else { return nil }
				return (rectDistance, charIndex)
			})
		guard let closest = distanceAndIndexes.sorted(by: {$0.0 < $1.0 }).first else { return  nil }
		return closest.1
	}
	
	public func attributes(at point:CGPoint, distance:CGFloat = 0.0)->([NSAttributedString.Key:Any], NSRange)? {
		guard let index = stringIndex(at: point, distance:distance) else { return nil }
		var effectiveRange:NSRange = NSRange(location:NSNotFound, length: 0)
		let attributes = attributedText.attributes(at: index, longestEffectiveRange: &effectiveRange
												   , in: NSRange(location: 0, length: (attributedText.string as NSString).length))
		return (attributes, effectiveRange)
	}
	
	///finds the link nearest the touch point
	public func nearestLink(at point:CGPoint, maxDistance:CGFloat = 12.0)->(NSRange, URL)? {
		guard let textFrame = ctFrame else { return nil }
		let pointInCTFrameCoords = CGPoint(x: point.x, y: bounds.size.height - point.y)
		let lines:[CTLine] = CTFrameGetLines(textFrame) as [AnyObject] as! [CTLine]
		var origins:[CGPoint] = [CGPoint](repeating: .zero, count: lines.count)
		CTFrameGetLineOrigins(textFrame, CFRange(location: 0, length: lines.count), &origins)
		let stringLength:Int = (attributedText.string as NSString).length
		let distanceAndIndexes:[(CGFloat, NSRange, URL)] = lines
			.enumerated()
			.compactMap({ index, line in
				//get the frame of the line
				let origin = origins[index]
				var lineRectInFrameCoords = CTLineGetImageBounds(line, nil)
				lineRectInFrameCoords.origin = lineRectInFrameCoords.origin + origin
				//determine if the touch is close enough
				let rectDistance = lineRectInFrameCoords.distance(to: pointInCTFrameCoords)
				guard rectDistance <= maxDistance else { return nil }
				//find the char index of the touch
				let closePoint = lineRectInFrameCoords.pointClosest(to:pointInCTFrameCoords)
				let closePointInLineCoords:CGPoint = closePoint - origin
				let charIndex = CTLineGetStringIndexForPosition(line, closePointInLineCoords)
				guard charIndex != kCFNotFound else { return nil }
				
				//enumerate ranges of attributes, and look for links, find their bounds and check distance to touch point
				//if there is more than one range with links, use the closer one.
				
				var anIndex:Int = CTLineGetStringRange(line).location
				var allLinkRanges:[(CGFloat, NSRange, URL)] = []
				let lineMax = CTLineGetStringRange(line).end
				while anIndex < lineMax {
					//get the effective range of attributes
					var effectiveRange:NSRange = NSRange(location:NSNotFound, length: 0)
					let attributes:[NSAttributedString.Key : Any] = attributedText.attributes(at: anIndex, longestEffectiveRange: &effectiveRange, in: NSRange(location: anIndex, length: lineMax - anIndex))
					defer {
						anIndex = min(lineMax, effectiveRange.end)
					}
					guard let link = attributes[.link] else {
						continue
					}
					//ensure the link is interpretable as a URL
					let url:URL
					if let urlLink:URL = link as? URL {
						url = urlLink
					}
					else if let linkString:String = link as? String
								,let urlLink:URL = URL(string: linkString) {
						url = urlLink
					}
					else { continue }
					
					//determine the distance to this if the point's x is less or greater than the beginning or end
					let fragmentRectMinX = CTLineGetOffsetForStringIndex(line, effectiveRange.location, nil)
					let fragmentRectMaxX = CTLineGetOffsetForStringIndex(line, effectiveRange.end, nil)
					if closePointInLineCoords.x < fragmentRectMinX {
						let diffX = fragmentRectMinX - closePointInLineCoords.x
						if diffX <= maxDistance {
							allLinkRanges.append((diffX, effectiveRange, url))
						}
					}
					else if closePointInLineCoords.x > fragmentRectMaxX {
						let diffX = closePointInLineCoords.x - fragmentRectMaxX
						if diffX <= maxDistance {
							allLinkRanges.append((diffX, effectiveRange, url))
						}
					}
					else {
						allLinkRanges.append((rectDistance, effectiveRange, url))
					}
				}
				guard let closestOnTheLine = allLinkRanges.sorted(by: {$0.0 < $1.0 }).first else { return nil }
				
				//determine if the range contains a link
				var effectiveRange:NSRange = NSRange(location:NSNotFound, length: 0)
				guard nil != attributedText.attribute(.link
														  ,at:closestOnTheLine.1.location
														  ,longestEffectiveRange:&effectiveRange
														  ,in:NSRange(location: 0, length: stringLength))
					else { return nil }
				
				return (closestOnTheLine.0, effectiveRange, closestOnTheLine.2)
			})
		//of the ranges which have links, get the one nearest the touch point
		guard let closest = distanceAndIndexes.sorted(by: {$0.0 < $1.0 }).first else { return  nil }
		return (closest.1, closest.2)
	}
	
	
	public func rects(range:NSRange)->[CGRect] {
		guard let textFrame = ctFrame else { return [] }
		let lines:[CTLine] = CTFrameGetLines(textFrame) as [AnyObject] as! [CTLine]
		var origins:[CGPoint] = [CGPoint](repeating: .zero, count: lines.count)
		CTFrameGetLineOrigins(textFrame, CFRange(location: 0, length: lines.count), &origins)
		return lines
			.enumerated()
			.compactMap({ (lineIndex, line )->(Int, CTLine, NSRange)? in
				guard let overlap = CTLineGetStringRange(line).intersection(range) else { return nil }
				return (lineIndex, line, overlap)
			})
			.map { lineIndex, line, overlap in
				var lineFrame = line.bounds(range:overlap)
				let origin = origins[lineIndex]
				lineFrame.origin += origin
				return lineFrame
			}
	}
	
	public var highlight:(NSRange, UIColor)? {
		didSet {
			guard let range = highlight else {
				highlightFrames = nil
				return
			}
			highlightFrames = (rects(range:range.0), range.1)
		}
	}
	
	public var highlightRadius:CGFloat = 2.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	private var highlightFrames:([CGRect], UIColor)? = nil {
		didSet {
			setNeedsDisplay()
		}
	}
	
	
	open override var forFirstBaselineLayout: UIView {
		return firstBaselineLayoutView
	}
	
	open override var forLastBaselineLayout: UIView {
		return lastBaselineLayoutView
	}
	
	private lazy var firstBaselineLayoutView:UIView = {
		let aView = UIView().forAutoLayout()
		aView.widthAnchor == 0.0
		aView.heightAnchor == 0.0
		return aView
	}()
	
	private lazy var lastBaselineLayoutView:UIView = {
		let aView = UIView().forAutoLayout()
		aView.widthAnchor == 0.0
		aView.heightAnchor == 0.0
		return aView
	}()
	
	//utility methods
	
	private func didInit() {
		
		isOpaque = false
		clearsContextBeforeDrawing = true
		accessibilityTraits = .staticText
		setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		setContentHuggingPriority(.defaultLow, for: .horizontal)
		setContentHuggingPriority(.defaultLow, for: .vertical)
		
		addSubview(firstBaselineLayoutView)
		|-firstBaselineLayoutView
		addSubview(lastBaselineLayoutView)
		lastBaselineLayoutView-|
		
		firstBaselineConstraint = bottomAnchor == firstBaselineLayoutView.bottomAnchor + 0.0
		lastBaselineConstraint = bottomAnchor == lastBaselineLayoutView.bottomAnchor + 0.0
	}
	
	
	open var preferredMaxLayoutWidth:CGFloat = 0.0 {
		didSet {
			if preferredMaxLayoutWidth == oldValue { return }
			invalidateIntrinsicContentSize()
		}
	}
	
	private var firstBaselineConstraint:NSLayoutConstraint?
	private var lastBaselineConstraint:NSLayoutConstraint?
	
	private var framesetter:CTFramesetter? {
		didSet {
			preferredMaxLayoutWidth = 0.0
			setNeedsUpdateConstraints()
			invalidateIntrinsicContentSize()
			recomputeFrame()
		}
	}
	
	
	private func recomputeFrame() {
		guard let setter = framesetter else {
			ctFrame = nil
			return }
		let path = CGPath(rect: bounds, transform: nil)
		let aFrame = CTFramesetterCreateFrame(setter
										   ,CFRange(location: 0, length: 0)	//0 length makes it use the whole thing
										   ,path
										   ,nil)
		ctFrame = aFrame
	}
	
	private var ctFrame:CTFrame? {
		didSet {
			updateBaselineConstraints()
			setNeedsUpdateConstraints()
			setNeedsDisplay()
		}
	}
	
	
	private func updateBaselineConstraints() {
		guard let textFrame = ctFrame
		,(CTFrameGetLines(textFrame) as NSArray).count > 0
		else {
			firstBaselineConstraint?.constant = 0.0
			lastBaselineConstraint?.constant = 0.0
			return
		}
		let linesCount:Int = (CTFrameGetLines(textFrame) as NSArray).count
		var origins:[CGPoint] = [CGPoint](repeating: .zero, count: linesCount)
		CTFrameGetLineOrigins(textFrame, CFRange(location: 0, length: linesCount), &origins)
		firstBaselineConstraint?.constant = origins[0].y
		lastBaselineConstraint?.constant = origins[origins.count - 1].y
	}
	
	
	//MARK: - UITraitEnvironment
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
		recomputeFrame()
	}
	
	
	//MARK: - UIView overrides
	
	open override class var requiresConstraintBasedLayout: Bool {
		return true
	}
	
	open override var frame: CGRect {
		didSet {
			recomputeFrame()
		}
	}
	
	open override var bounds: CGRect {
		didSet {
			recomputeFrame()
		}
	}
	
	open override func draw(_ rect: CGRect) {
		//background
		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.setFillColor((backgroundColor ?? .clear).cgColor)
		context.fill(bounds)
		guard let coreTextFrame = ctFrame else { return }
		//highlights
		context.translateBy(x: 0.0, y: bounds.height)
		context.scaleBy(x: 1.0, y: -1.0)
		if let frames = highlightFrames {
			context.setFillColor(frames.1.cgColor)
			for aFrame in frames.0 {
				let rounded = CGPath(roundedRect: aFrame.insetBy(dx: -highlightRadius, dy: -highlightRadius), cornerWidth: highlightRadius, cornerHeight: highlightRadius, transform: nil)
				context.addPath(rounded)
				context.fillPath()
			}
		}
		//text
		CTFrameDraw(coreTextFrame, context)
	}

	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return systemLayoutSizeFitting(size)
	}
	
	open override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
		return systemLayoutSizeFitting(targetSize
									   ,withHorizontalFittingPriority: .fittingSizeLevel
									   ,verticalFittingPriority: .fittingSizeLevel)
	}
	
	
	open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		guard let setter = framesetter else { return .zero }
		var size:CGSize = targetSize
		if targetSize.width == 0.0 {
			size.width = CGFloat.greatestFiniteMagnitude
		}
		size.height = CGFloat.greatestFiniteMagnitude
		let finalSize = CTFramesetterSuggestFrameSizeWithConstraints(setter
															,CFRange(location: 0, length: 0)	//0 length makes it use the whole thing
															,nil
															,size
															,nil)
		return finalSize
	}
	
	open override func layoutSubviews() {
		preferredMaxLayoutWidth = bounds.width
		super.layoutSubviews()
	}
	
	open override var intrinsicContentSize: CGSize {
		return systemLayoutSizeFitting(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
		
	}
	
}


extension CFRange {
	
	func intersection(_ range:NSRange)->NSRange? {
		let selfEnd = self.location + self.length
		let rangeEnd = range.location + range.length
		if selfEnd <= range.location {
			return nil
		}
		if rangeEnd <= self.location {
			return nil
		}
		let newEnd = min(selfEnd, rangeEnd)
		let newLocation = max(self.location, range.location)
		return NSRange(location: newLocation, length: newEnd - newLocation)
	}
	var end:Int {
		if location == kCFNotFound {
			return kCFNotFound
		}
		return location + length
	}
	
}


extension CTLine {
	
	func bounds(range:NSRange)->CGRect {
		let bounds = CTLineGetImageBounds(self, nil)
		let left = CTLineGetOffsetForStringIndex(self, range.location, nil)
		let right = CTLineGetOffsetForStringIndex(self, range.upperBound, nil)
		return CGRect(x: left, y: bounds.origin.y, width: right - left, height: bounds.size.height)
	}
	
}

extension NSRange {
	var end:Int {
		if location == NSNotFound {
			return NSNotFound
		}
		return location + length
	}
}
