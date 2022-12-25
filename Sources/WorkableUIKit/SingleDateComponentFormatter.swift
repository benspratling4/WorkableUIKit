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
		//but this unit may not fit integrally into the larger
		let allUnits = [Calendar.Component].inDescendingMagnitudeOrder.filter({ allowedUnits.contains($0) })
		guard let oneMoreUnitAfterFloor = calendar.date(byAdding: roundedUnit, value: 1, to: actualTimeOfFloor) else { return nil }
		guard let string = residualFormatter.string(from: componentsFloor) else { return nil }
		func returnByAddingOne()->(String, TimeInterval)? {
			//this code assumes units fit integrally into the next larger unit, which is fine until weeks into months
			return (string, oneMoreUnitAfterFloor.timeIntervalSince(endDate))
		}
		let allComponentsAtFloor = calendar.dateComponents(allowedUnits, from:startDate, to: actualTimeOfFloor)
		let oneUnitLargerComponents = calendar.dateComponents(allowedUnits, from:startDate, to: oneMoreUnitAfterFloor)
		let largerUnits = allUnits.unitsLargerThan(roundedUnit)
		for aLargerUnit in largerUnits.reversed() {
			if oneUnitLargerComponents.value(for: aLargerUnit) != allComponentsAtFloor.value(for: aLargerUnit) {
				//the next unit will be reached after actualTimeOfFloor but at or before oneMoreUnitAfterFloor
				let smallerComponentsToIgnore = allowedUnits.filter({ !largerUnits.contains($0) }).union([roundedUnit])
				let biggerFloor:DateComponents = oneUnitLargerComponents.settingComponentsToZero([Calendar.Component](smallerComponentsToIgnore))
				guard let timeAtBiggerFloor = calendar.date(byAdding: biggerFloor, to: startDate) else { continue }
				return (string, timeAtBiggerFloor.timeIntervalSince(endDate))
			}
		}
		//none of the larger unit were different, we can use the oneMoreUnitAfterFloor as the next time just fine
		return returnByAddingOne()
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
			let valueOrNil = value(for: component)
			guard let value = valueOrNil else { continue }
			if value > 0 {
				let remainingComponents = [Calendar.Component](units[(componentIndex+1)...])
				//if one of the allowed unit is non-zero, set the rest to zero
				return settingComponentsToZero(remainingComponents)
			}
		}
		//if none of the allowed units was non-zero, then we need to
		return ceilIfNonZero(allowedUnits:allowedUnits)
	}
	
	func floorAndRoundedUnit(allowedUnits:[Calendar.Component] = .inDescendingMagnitudeOrder)->(DateComponents, Calendar.Component) {
		let units = [Calendar.Component].inDescendingMagnitudeOrder.filter({ allowedUnits.contains($0) })
		
		for (componentIndex, component) in units.enumerated() {
			let valueOrNil = value(for: component)
			guard let value = valueOrNil else { continue }
			if value > 0 {
				let remainingComponents = [Calendar.Component](units[(componentIndex+1)...])
				return (settingComponentsToZero(remainingComponents)
					, component)
			}
		}
		let (ceil, ceilUnitOrNil) = ceilIfNonZeroAndUnit(allowedUnits:allowedUnits)
		return (ceil, ceilUnitOrNil ?? .nanosecond)
	}
	
	func settingComponentsToZero(_ components:[Calendar.Component])->DateComponents {
		var newValue = self
		for component in components {
			newValue.setValue(nil, for: component)
		}
		return newValue
	}
	
	//if this date components is non-zero, but the value is below the allowed units, then round it up to the smallest unit
	func ceilIfNonZero(allowedUnits:[Calendar.Component] = .inDescendingMagnitudeOrder)->DateComponents {
		return ceilIfNonZeroAndUnit(allowedUnits:allowedUnits).0
	}
	
	//if this date components is non-zero, but the value is below the allowed units, then round it up to the smallest unit and report which unit that was
	func ceilIfNonZeroAndUnit(allowedUnits:[Calendar.Component] = .inDescendingMagnitudeOrder)->(DateComponents, Calendar.Component?) {
		//if allowed units are non-zero, return self
		for unit in allowedUnits {
			if let unitValue = value(for: unit) {
				if unitValue > 0, unitValue < Int64.max {
					return (self, nil)
				}
			}
		}
		
		//in self, if units smaller than the smallest unit in allowedUnits
		guard let lastIndex = allowedUnits
			.compactMap({ [Calendar.Component].inDescendingMagnitudeOrder.lastIndex(of:$0) })
			.sorted(by: >)
			.first
			else { return (self, nil) }
		
		let smallestAllowedUnit = [Calendar.Component].inDescendingMagnitudeOrder[lastIndex]
		var newComponents = DateComponents(calendar: calendar, timeZone: timeZone)
		if let smallestValue = value(for: smallestAllowedUnit)
			, smallestValue > 0
			, smallestValue < Int64.max {
			//we already have a non-zero smallest unit
		}
		else {
			newComponents.setValue(1, for: smallestAllowedUnit)
		}
		return (newComponents, smallestAllowedUnit)
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
	
	//assuming self is ordered in descending order,
	//returns nil if there are no larger units
	func nextLargerAllowedUnit(than unit:Calendar.Component)->Calendar.Component? {
		guard let index = firstIndex(of: unit)
			,index > 0
			else { return nil }
		return self[index - 1]
	}
	
	
	func unitsLargerThan(_ aUnit:Calendar.Component)->[Calendar.Component] {
		guard let index = firstIndex(of: aUnit)
			,index > 0
			else { return [] }
		return [Calendar.Component](self[0..<index])
	}
	
}
