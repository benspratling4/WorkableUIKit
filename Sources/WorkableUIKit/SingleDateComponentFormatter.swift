//
//  SingleDateComponentFormatter.swift
//  
//
//  Created by Ben Spratling on 12/13/22.
//

import Foundation


///Ever wanted to get 1 date component out of a DateComponentsFormatter,
///But discovered the rounding behavior makes the output useless?
///ever wanted to set a Timer and update the values when they need to bump over to the next rounded unit
///Well, now you can
public struct SingleDateComponentFormatter {
	
	public init(calendar:Calendar = .autoupdatingCurrent
				,allowedUnits:Set<Calendar.Component> = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]) {
		self.calendar = calendar
		self.allowedUnits = allowedUnits
		residualFormatter = DateComponentsFormatter()
		residualFormatter.maximumUnitCount = 1
		residualFormatter.zeroFormattingBehavior = [.dropLeading, .dropTrailing]
		residualFormatter.allowsFractionalUnits = false
		residualFormatter.unitsStyle = .abbreviated
		residualFormatter.allowedUnits = NSCalendar.Unit(allowedUnits)
	}
	
	public func string(from startDate:Date, to endDate:Date)->String? {
		let components = calendar.dateComponents(allowedUnits, from: startDate, to: endDate)
		let componentsFloor = components.floor(allowedUnits: [Calendar.Component](allowedUnits))
		return residualFormatter.string(from: componentsFloor)
	}
	
	///generates not only the floor-rounded string, but also a time interval until it should change
	public func stringAndIntervalToChange(from startDate:Date, to endDate:Date)->(String, TimeInterval)? {
		let components = calendar.dateComponents(allowedUnits, from: startDate, to: endDate)
		let (componentsFloor, roundedUnit) = components.floorAndRoundedUnit(allowedUnits: [Calendar.Component](allowedUnits))
		//to make the calendar give us the ceil, we'll add 1 of the largest non-zero unit to the components, and floor that
		guard let actualTimeOfFloor = calendar.date(byAdding: componentsFloor, to: startDate) else { return nil }
		guard let oneMoreUnitAfterFloor = calendar.date(byAdding: roundedUnit, value: 1, to: actualTimeOfFloor) else { return nil }
		guard let string = residualFormatter.string(from: componentsFloor) else { return nil }
		return (string, oneMoreUnitAfterFloor.timeIntervalSince(endDate))
	}
	
	public var calendar:Calendar
	public var allowedUnits:Set<Calendar.Component> {
		didSet {
			residualFormatter.allowedUnits = NSCalendar.Unit(allowedUnits)
		}
	}
	public var residualFormatter:DateComponentsFormatter
	
}



extension NSCalendar.Unit {
	init?(_ component:Calendar.Component) {
		switch component {
		case .nanosecond:
			self = .nanosecond
		case .second:
			self = .second
		case .minute:
			self = .minute
		case .hour:
			self = .hour
		case .day:
			self = .day
		case .weekdayOrdinal:
			self = .weekdayOrdinal
		case .weekday:
			self = .weekday
		case .weekOfMonth:
			self = .weekOfMonth
		case .weekOfYear:
			self = .weekOfYear
		case .month:
			self = .month
		case .quarter:
			self = .quarter
		case .year:
			self = .year
		case .yearForWeekOfYear:
			self = .yearForWeekOfYear
		case .era:
			self = .era
		case .calendar:
			self = .calendar
		case .timeZone:
			self = .timeZone
		@unknown default:
			return nil
		}
	}
	
	init(_ components:Set<Calendar.Component>) {
		var calendarUnit:NSCalendar.Unit = NSCalendar.Unit()
		for unit in components {
			guard let calUnit = NSCalendar.Unit(unit) else { continue }	//fails only for new cases of Calendar.Component
			calendarUnit.insert(calUnit)
		}
		self = calendarUnit
	}
	
}


extension DateComponents {
	func floor(allowedUnits:[Calendar.Component] = .inDescendingMagnitudeOrder)->DateComponents {
		let units = [Calendar.Component].inDescendingMagnitudeOrder.filter({ allowedUnits.contains($0) })
		for (componentIndex, component) in units.enumerated() {
			let valueOrNil = self.value(for: component)
			guard let value = valueOrNil else { continue }
			if value > 0 {
				let remainingComponents = [Calendar.Component](units[(componentIndex+1)...])
				return settingComponentsToZero(remainingComponents)
			}
		}
		return self
	}
	
	func floorAndRoundedUnit(allowedUnits:[Calendar.Component] = .inDescendingMagnitudeOrder)->(DateComponents, Calendar.Component) {
		let units = [Calendar.Component].inDescendingMagnitudeOrder.filter({ allowedUnits.contains($0) })
		for (componentIndex, component) in units.enumerated() {
			let valueOrNil = self.value(for: component)
			guard let value = valueOrNil else { continue }
			if value > 0 {
				let remainingComponents = [Calendar.Component](units[(componentIndex+1)...])
				//TODO: remove disallowed units completely
				
				return (settingComponentsToZero(remainingComponents), component)
			}
		}
		return (self, .nanosecond)
	}
	
	func settingComponentsToZero(_ components:[Calendar.Component])->DateComponents {
		var newValue = self
		for component in components {
			newValue.setValue(nil, for: component)
		}
		return newValue
	}
	
}


extension Array where Element == Calendar.Component {
	
	static let inDescendingMagnitudeOrder:[Calendar.Component] = [
		.era,
		.year,
		.yearForWeekOfYear,
		.quarter,
		.month,
		.weekOfYear,
		.weekOfMonth,
		.weekday,
		.day,
		.weekdayOrdinal,
		.hour,
		.minute,
		.second,
		.nanosecond,
	]
	
	
}

