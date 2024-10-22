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
    
    public var amORpm: DayOrNight {
        if hour >= 12 {
            return .pm
        } else {
            return .am
        }
    }
//    public var quadrant: ClockQuadrant = .first
    
    public init(hour: Int, minute: Int) {
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
