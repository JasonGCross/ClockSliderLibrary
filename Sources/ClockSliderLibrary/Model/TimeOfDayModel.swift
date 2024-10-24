//
//  TimeOfDayModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-21.
//


import Foundation

public struct TimeOfDayModel: Equatable, CustomDebugStringConvertible {
    private(set) var hour: Int = 0
    private(set) var minute: Int = 0
    
    public init(hour: Int = 0, minute: Int = 0) {
        self.setHours(hour)
        self.setMinutes(minute)
    }
    
    public var debugDescription: String {
        var sb = ""
        sb += "▿ hour : \(hour)\n"
        sb += "▿ minute : \(minute)\n"
        return sb
    }
    public static func == (lhs: TimeOfDayModel, rhs: TimeOfDayModel) -> Bool {
        let value = (lhs.hour == rhs.hour) && (lhs.minute == rhs.minute)
        return value
    }
}

extension TimeOfDayModel {
    
    public var totalMinutes: Int {
        hour * 60 + minute
    }
    
    public var amORpm: DayOrNight {
        if hour >= 12 {
            return .pm
        } else {
            return .am
        }
    }
    
    public static var now: TimeOfDayModel {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        return TimeOfDayModel(
            hour: components.hour ?? 0,
            minute: components.minute ?? 0)
    }
    
    public func getFoundationDateWithOnlyHoursAndMinutes() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(hour: self.hour, minute: self.minute)
        let date = calendar.date(from: components)
        return date ?? Date()
    }
    
    public mutating func setMinutes(_ minutes: Int) {
        var newHour = 0
        var newMinute = minutes
        
        if minutes < 0 {
            let quotient = (Double(minutes) / 60.0).rounded(.down)
            let hoursToAdd = -1 * Int(quotient)
            newMinute = minutes + (hoursToAdd * 60)
            newHour = -hoursToAdd
        }
        
        if newMinute >= 60 {
            let oldMin = newMinute
            let remainder = newMinute % 60
            newMinute = remainder
            let quotient = (Double(oldMin) / 60.0).rounded(.towardZero)
            let hoursToAdd = Int(quotient)
            newHour = Int(hoursToAdd)
        }
        self.minute = newMinute
        self.setHours(self.hour + newHour)
    }
    
    public mutating func setHours(_ hours: Int) {
        var newHour = hours
        
        if hours < 0 {
            let quotient = (Double(hours) / 24.0).rounded(.down)
            let daysToAdd = -1 * Int(quotient)
            newHour = hours + (daysToAdd * 24)
        }
        
        if newHour >= 24 {
            let remainder = newHour % 24
            newHour = remainder
        }
        self.hour = newHour
    }
    
    public func addingTimeInterval(_ timeInterval: TimeInterval) -> TimeOfDayModel {
        let minutesToAdd = timeInterval / 60.0
        let totalMinutes = self.minute + Int(minutesToAdd.rounded())
        
        let minutesComponents = TimeOfDayModel.timeModelFromMinutes(totalMinutes)
        let totalHours = self.hour + minutesComponents.hour
        let hourComponents = TimeOfDayModel.timeOnlyFromHours(totalHours)
        
        return TimeOfDayModel(hour: hourComponents.hour, minute: minutesComponents.minute)
    }
    
    /**
     Meant to be used during a slide motion, where the change in the time of day
     is normally very small.
     For example, if the current time is 3:00pm, and the slider changes one minute,
     the new time must be 3:01pm.
     The problem is that the newTotalMinutes will always represent a time between midnight
     and noon (i.e. 0 hours up to 12 hours), so the above new time might look like 3:01am,
     instead of the reality of 3:01pm.
     
     This function takes a raw total number of minutes and makes an appropriate adjustment
     to this model so that it accurately reflects the new time.
     */
    public mutating func adjustMinutesSlightly(newTotalMinutes: Int) {
        // get rid of the complication of dealing with a midnight boundary
        let minutesInHalfADay = 12 * 60
        let timeToAdd = 5 * minutesInHalfADay
        let currentTotalMinutes = self.totalMinutes
        let currentMinutesWithPadding = currentTotalMinutes + timeToAdd
        let newMinutesWithPadding = newTotalMinutes + timeToAdd
        
        // make sure that these totals agree within reason
        let difference = currentMinutesWithPadding - newMinutesWithPadding
        let expectedMaxChangeInMinutes = 120
        let threshold = minutesInHalfADay - expectedMaxChangeInMinutes
        guard abs(Double(difference)) > Double(threshold) else {
            self = TimeOfDayModel.timeModelFromMinutes(newTotalMinutes)
            return
        }
        
        // need to either add 24 hours or subtract 24 hours
        let unitsToAdd = (Double(difference) / Double(minutesInHalfADay)).rounded()
        let minutesToAdd = Int(unitsToAdd) * minutesInHalfADay
        let adjustedMinutes = newTotalMinutes + minutesToAdd
        self = TimeOfDayModel.timeModelFromMinutes(adjustedMinutes)
        return
    }
    
    public func timeIntervalSince(_ otherTimeModel: TimeOfDayModel) -> TimeInterval {
        let date1 = self.getFoundationDateWithOnlyHoursAndMinutes()
        let date2 = otherTimeModel.getFoundationDateWithOnlyHoursAndMinutes()
        let value = date1.timeIntervalSince(date2)
        return value
    }
    
    public static func timeOnlyFromFoundationDate(_ date: Date) -> TimeOfDayModel {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return TimeOfDayModel(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }
    
    public static func timeModelFromMinutes(_ minutes: Int) -> TimeOfDayModel {
        var hour = 0
        var min = minutes
        
        if minutes < 0 {
            let quotient = (Double(minutes) / 60.0).rounded(.down)
            let hoursToAdd = -1 * Int(quotient)
            min = minutes + (hoursToAdd * 60)
            hour = -hoursToAdd
        }
        
        if min >= 60 {
            let oldMin = min
            let remainder = min % 60
            min = remainder
            let quotient = (Double(oldMin) / 60.0).rounded(.towardZero)
            let hoursToAdd = Int(quotient)
            hour = Int(hoursToAdd)
        }
        return TimeOfDayModel(hour: hour, minute: min)
    }
    
    public static func timeOnlyFromHours(_ rawHours: Int) -> TimeOfDayModel {
        let min = 0
        var hour = rawHours
        
        if rawHours < 0 {
            let quotient = (Double(rawHours) / 24.0).rounded(.down)
            let daysToAdd = -1 * Int(quotient)
            hour = rawHours + (daysToAdd * 24)
        }
        
        if hour >= 24 {
            let remainder = hour % 24
            hour = remainder
        }
        
        return TimeOfDayModel(hour: hour, minute: min)
    }
}
