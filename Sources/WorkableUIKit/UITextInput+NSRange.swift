//
//  UITextInput+NSRange.swift
//  WorkableUIKit
//
//  Created by Ben Spratling on 3/6/22.
//

import Foundation
import UIKit


extension UITextInput {
	
	///for convenience, auto converts to/from the selectedTextRange
	public var selectedNSRange:NSRange {
		get {
			return nsRange(for:selectedTextRange)
		}
		set {
			selectedTextRange = textRange(for: newValue)
		}
	}
	
	///the UITextRange must come from self since changes were made
	public func nsRange(for textRange:UITextRange?)->NSRange {
		guard let range = textRange else {
			return NSRange(location: NSNotFound, length: 0)
		}
		let location = offset(from: beginningOfDocument, to: range.start)
		let length = offset(from: range.start, to: range.end)
		return NSRange(location: location, length: length)
	}
	
	///the NSRange must be calculated for the self since any changes were made
	public func textRange(for nsRange:NSRange)->UITextRange? {
		guard nsRange.location != NSNotFound
			,let start = position(from: beginningOfDocument, offset: nsRange.location)
			,let end = position(from: start, offset: nsRange.length)
			else { return nil }
		return textRange(from: start, to: end)
	}
	
	///you can use this to find out what the string would be after the proposed change inside the delegate method shouldChangeCharactersIn
	public func changingCharacters(in range:NSRange, replacementString:String)->String? {
		guard let startOfRange = position(from: beginningOfDocument, offset: range.location)
			,let endOfRange = position(from: startOfRange, offset: range.length)
			,let initialRange = textRange(from: beginningOfDocument, to: startOfRange)
			,let finalRange = textRange(from: endOfRange, to: endOfDocument)
			,let preRangeText = text(in:initialRange)
			,let postRangeText = text(in:finalRange)
			else { return nil }
		return preRangeText + replacementString + postRangeText
	}
	
	///with the current selected range, where should the selection range end up after making the replacement
	public func selectedRangeAfterChangingCharacters(in range:NSRange, replacementString:String)->NSRange {
		//get necessary information, otherwise give up
		guard let currentSelectedTextRange = selectedTextRange
			,let startOfReplacementRange = position(from: beginningOfDocument, offset: range.location)
			else { return NSRange(location: NSNotFound, length: 0) }
		//if the end of the seleciton is before or at the beginning of the replacement range, then we don't change it
		if compare(currentSelectedTextRange.end, to: startOfReplacementRange) != .orderedDescending // == .orderedAscending || == .orderedSame
			, compare(currentSelectedTextRange.start, to: startOfReplacementRange) == .orderedAscending {
			return selectedNSRange
		}
		//find out how long the text will be after the replacement, up to the end of the text which replaces the old range
		guard let endOfReplacementRange = position(from: startOfReplacementRange, offset: range.length)
			,let initialRange = textRange(from: beginningOfDocument, to: startOfReplacementRange)
			,let preRangeText = text(in:initialRange)
			else {
				//those values were necessary to do the computation, so return no selection
				return NSRange(location: NSNotFound, length: 0)
			}
		let newStringUpToEndOfReplacedText = preRangeText + replacementString
		let offSetAtEndOfReplacedRange = (newStringUpToEndOfReplacedText as NSString).length
		let utf16CodePointsAfterEditedRange:Int
		if compare(endOfReplacementRange, to:currentSelectedTextRange.end) == .orderedAscending {
			//we return a zero-length range the same number of characters after the replacement range ended
			utf16CodePointsAfterEditedRange = offset(from: endOfReplacementRange, to: currentSelectedTextRange.start)
		}
		else {
			//otherwise, the selection range is in or at the end of the replacement range, so we'll say 0
			utf16CodePointsAfterEditedRange = 0
		}
		
		return NSRange(location: offSetAtEndOfReplacedRange + utf16CodePointsAfterEditedRange, length: 0)
	}
}
