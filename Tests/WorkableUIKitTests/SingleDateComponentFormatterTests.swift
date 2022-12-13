//
//  SingleDateComponentFormatterTests.swift
//  
//
//  Created by Ben Spratling on 12/13/22.
//

import XCTest

@testable import WorkableUIKit

class SingleDateComponentFormatterTests: XCTestCase {
	
	//start date, end date, target formatted string,
	let floorTestCases:[(Date, Date, String, TimeInterval)] = [
		(Date(timeIntervalSince1970: 1670278585.556899), Date(timeIntervalSince1970: 1670880385.556899), "6d", 3000.0),
		(Date(timeIntervalSince1970: 1670278585.556899), Date(timeIntervalSince1970: 1670278586.556899), "1s", 1.0),
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670200060.000000), "1m", 60.0),
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670203590.000000), "59m", 10.0),
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670203599.000000), "59m", 1.0),
	]
	
	lazy var testCalendar:Calendar = {
		var cal = Calendar(identifier: .gregorian)
		cal.locale = testLocale
		cal.timeZone = testTimeZone
		return cal
	}()
	
	lazy var testTimeZone:TimeZone = TimeZone(identifier: "CST")!
	
	lazy var testLocale:Locale = Locale(identifier: "en_US")
	
	func testFlooringAndTimeInterval()throws {
		let formatter = SingleDateComponentFormatter(calendar:testCalendar, allowedUnits: [.year, .month, .weekOfMonth, .day, .hour, .minute, .second])
		
		for (startDate, endDate, targetString, targetInterval) in floorTestCases {
			let (formatted, nextInterval) = try XCTUnwrap(formatter.stringAndIntervalToChange(from: startDate, to: endDate))
			XCTAssertEqual(formatted, targetString)	//TODO: add dates for debugging?
			XCTAssertEqual(nextInterval, targetInterval, accuracy: 2.0)
		}
	}

}
