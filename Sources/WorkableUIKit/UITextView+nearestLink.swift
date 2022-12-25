//
//  File.swift
//  
//
//  Created by Ben Spratling on 12/11/21.
//

import Foundation
import UIKit


extension UITextView {
	
	public func nearestLink(at point:CGPoint, maxDistance:CGFloat = 12.0)->(NSRange, URL)? {
		guard let textStorage = layoutManager.textStorage else { return nil }
		let nsString:NSString = attributedText.string as NSString
		let fullCharacterRange:NSRange = NSRange(location: 0, length: nsString.length)
		let fullGlyphRange = layoutManager.glyphRange(forCharacterRange: fullCharacterRange, actualCharacterRange: nil)
		var distanceAndIndexes:[(CGFloat, NSRange, URL)] = []
		layoutManager.enumerateLineFragments(forGlyphRange: fullGlyphRange) { rect, usedRect, textContainer, glyphRange, stop in
			let charRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
			let subString:NSAttributedString = textStorage.attributedSubstring(from: charRange)
			//enumerate the ranges of attributes in the substring
			var anIndex:Int = 0
			let subStringLength:Int = subString.length
			while anIndex < subStringLength {
				//get the range of the substring with the common attributes
				var effectiveRange:NSRange = NSRange(location:NSNotFound, length: 0)
				let attributes:[NSAttributedString.Key : Any] = subString.attributes(at: anIndex, longestEffectiveRange: &effectiveRange, in: NSRange(location: anIndex, length: subStringLength - anIndex))
				defer {
					//clean up to go to next range of different attributes
					anIndex = effectiveRange.end
				}
				//only consider this range if it has a link
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
				
				//get the frame of the range
				var subRange = effectiveRange
				subRange.location += charRange.location
				let subGlyphRange = self.layoutManager.glyphRange(forCharacterRange: subRange, actualCharacterRange: nil)
				
				let startX = self.layoutManager.location(forGlyphAt: subGlyphRange.location).x
				let endX = self.layoutManager.location(forGlyphAt: max(subGlyphRange.location, subGlyphRange.end-1)).x
				let fragmentRect = CGRect(x: startX, y: usedRect.minY, width: endX - startX, height: usedRect.height)
				let distanceToUsedRect:CGFloat = fragmentRect.distance(to: point)
				if distanceToUsedRect <= maxDistance {
					distanceAndIndexes.append((distanceToUsedRect, subRange, url))
				}
			}
		}
		guard let closestFragment = distanceAndIndexes.sorted(by: { $0.0 < $1.0 }).first else { return nil }
		//get the full effective range of the stuff
		var effectiveRange:NSRange = NSRange(location:NSNotFound, length: 0)
		guard nil != attributedText.attribute(.link
												  ,at:closestFragment.1.location
												  ,longestEffectiveRange:&effectiveRange
												  ,in:fullCharacterRange)
			else { return nil }
		
		return (effectiveRange, closestFragment.2)
	}
	
}

