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
		
		//Test seconds
		(Date(timeIntervalSince1970: 1670278585.556899), Date(timeIntervalSince1970: 1670278586.556899), "1s", 1.0),
		
		//Test Minutes
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670200060.000000), "1m", 60.0),
		//10 seconds less than an hour
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670203590.000000), "59m", 10.0),
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600003599.0), "59m", 1.0),
		
		
		//test hours
		//test an even hour
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600003600.0), "1h", 3600.0),
		//one second more than an hour
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600003601.0), "1h", 3599.0),
		//1 minute more than an hour
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600003660.0), "1h", 3540.0),
		
		//2 hours
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600007200.0), "2h", 3600.0),
		
		//one second less than 2 hours
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600007199.0), "1h", 1.0),
		
		//1 minute less than 2 hours
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600007140.0), "1h", 60.0),
		//TODO:
		
		//TODO: test days
		//TODO: exactly 1 day
		//TODO: one second less than 1 day
		//TODO: one second less than 2 days
		//TODO: one minute less than 1 day
		//TODO: one minute less than 2 days
		//TODO: one hour less than 1 day
		//TODO: one hour less than 2 days
		//TODO: one hour less than 7 days
		
		//regression for an interval that definitely failed at one time
		(Date(timeIntervalSince1970: 1670278585.556899), Date(timeIntervalSince1970: 1670880385.556899), "6d", 3000.0),
		
		
		//Test weeks
		
		//1 week == 604800 seconds
		//one second less than 1 week
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600604799.0), "6d", 1.0),
		//1 week
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600604800.0), "1w", 604800.0),
		//1 second more than 1 week
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1600604801.0), "1w", 604799.0),
		
		//2 weeks
		
		
		
		//3 weeks
		
		
		
		//4 weeks
		
		
		
		//1 second less than 1 month
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1602591999.0), "4w", 1.0),
		
		
		//Calendar takes the number of days in the month into account when calculating diffs
		//how do we transition to months?
			//may be day dependent?
		
		//transition across 30-day month
		//the time till 2 months takes into account that the next month has 31 days
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1602592000.0), "1mo", 2682000),
		//but this goes from a 31-day month into a 30-day month, followed by a 31-
		(Date(timeIntervalSince1970: 1602592000.0), Date(timeIntervalSince1970: 1605274000.0), "1mo", 2592000.0),
		

		
		//TODO: test months
		
		
		
		//TODO: test years
		
//		1600000000.0
//		0031536000.0	=	 365 days
		
		//1 second less than 1 year
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1631535999.0), "11mo", 1.0),
		//1 year
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1631536000.0), "1y", 31536000.0),
		//1 second more than 1 year
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1631536001.0), "1y", 31535999.0),
		
		
		//1 second less than 2 years
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1663071999), "1y", 1.0),
		//2 years
		(Date(timeIntervalSince1970: 1600000000.0), Date(timeIntervalSince1970: 1663072000), "2y", 31536000.0),
		
		
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
			XCTAssertEqual(formatted, targetString, "diff \(endDate.timeIntervalSince(startDate))")	//TODO: add dates for debugging?
			XCTAssertEqual(nextInterval, targetInterval, accuracy: 2.0, "diff \(endDate.timeIntervalSince(startDate))")
		}
	}
	
	
	//start date, end date, target formatted string,
	let ceilTestCases:[(Date, Date, String, TimeInterval)] = [
		
		//1 second, which would round up to the minimum 1m, and not change to 2m for 119 more seconds
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670200001.000000), "1m", 119.0),
		
		//ensure nano seconds don't screw it up
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670200000.000001), "1m", 119.999999),
		
		//59 seconds
		(Date(timeIntervalSince1970: 1670200000.000000), Date(timeIntervalSince1970: 1670200059.000000), "1m", 61.0),
		
	]
	
	
	func testCeilAndTimeInterval()throws {
		let formatter = SingleDateComponentFormatter(calendar:testCalendar, allowedUnits: [.year, .month, .weekOfMonth, .day, .hour, .minute])
		
		for (startDate, endDate, targetString, targetInterval) in ceilTestCases {
			let (formatted, nextInterval) = try XCTUnwrap(formatter.stringAndIntervalToChange(from: startDate, to: endDate))
			XCTAssertEqual(formatted, targetString)	//TODO: add dates for debugging?
			XCTAssertEqual(nextInterval, targetInterval, accuracy: 2.0)
		}
	}

}
