//
//  BaseClockModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

/**
 Unlike a normal clock, this clock has two hour hands, and no minute hands.
 One hour hand represents start time, the other finish time.
 Each hand moves in very fine movements, such that its angle can be used to
 determine a time in hours, minutes, seconds, and fraction of seconds.
 */
public protocol BaseClockModel {
    var startTime: TimeOfDayModel {get set}
    var finishTime: TimeOfDayModel {get set}
    
    /// helps distinguish between the first and second rotation around the clock
    var clockRotationCount: ClockRotationCount {get set}
    var maximumTimeDuration: Int? {get set}
    
    var startTimeInMinutes: CGFloat {get set}
    var finishTimeInMinutes: CGFloat {get set}
    var startDayOrNightString: String {get set}
    var finishDayOrNightString: String {get set}
    var timeRange: Int {get}
    
    mutating func advanceRotationCountIfAllowed()
    
    mutating func setStartDayOrNight(_ dayOrNight: DayOrNight) -> Void
    mutating func setFinishDayOrNight(_ dayOrNight: DayOrNight) -> Void
    mutating func incrementDuration(minutes: Int)
    mutating func setInitialDuration(minutes: Int)
    static func convertMinutesToSafeMinutes(_ unsafeMinutes: CGFloat, clockType: ClockType) -> CGFloat
    
    mutating func changeRotationCountIfNeeded(_ oldTimeRange: CGFloat, newTimeRange: CGFloat)
    static func timeSpanBetween(_ startTime: CGFloat, finishTime:CGFloat) -> CGFloat
    
    var test_startTimeOfDayModel: TimeOfDayModel {get}
    var test_finishTimeOfDayModel: TimeOfDayModel {get}
    
    var clockType: ClockType {get}
    var oneRotation: Int {get}
    var halfRotation: Int {get}
    var quarterRotation: Int {get}
    var threeQuarterRotation: Int {get}
}

extension BaseClockModel {
    var startDayOrNightString: String {
        return self.startTime.amORpm.rawValue
    }
    
    var finishDayOrNightString: String {
        return self.finishTime.amORpm.rawValue
    }
    
    var oneRotation: Int { self.clockType.rawValue * 60 }
    var halfRotation: Int { self.clockType.rawValue * 30 }
    var quarterRotation: Int { self.clockType.rawValue * 15 }
    var threeQuarterRotation: Int { self.clockType.rawValue * 45 }
    var almostFullRotation: Int { self.clockType.rawValue * 60 * (640/720) }
    
    static func timeSpanBetween(_ startTime: CGFloat, finishTime:CGFloat) -> CGFloat {
        // we cannot just perform simple subtraction because we are dealing with a clock
        // meaning from 11:00pm to 3:00am crosses the day boundary,
        // which must be taken into account
        
        let calendar: Calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        var startTimeComponents = DateComponents()
        var finishTimeComponents = DateComponents()
        startTimeComponents.minute = Int(round(startTime))
        finishTimeComponents.minute = Int(round(finishTime))
        
        guard let startTimeDateObject = calendar.date(from: startTimeComponents),
            var finishTimeDateObject = calendar.date(from: finishTimeComponents) else {
                return 0
        }
        
        // have we taken into account the "crossing-midnight-boundary" issue yet?
        if (finishTimeDateObject < startTimeDateObject) {
            // add another 12 hours to the finish
            finishTimeComponents.hour = 12
            guard let adjustedFinishObject = calendar.date(from: finishTimeComponents) else {
                return 0
            }
            finishTimeDateObject = adjustedFinishObject
        }
        
        let secondDifference = finishTimeDateObject.timeIntervalSince(startTimeDateObject)
        let selectedTime: CGFloat = CGFloat(round(secondDifference / 60.0))
        
        return selectedTime
    }
    
    mutating func advanceRotationCountIfAllowed() {
        if (self.maximumTimeDuration == nil) || (self.maximumTimeDuration! > oneRotation) {
            self.clockRotationCount.incrementCount()
        }
    }
    
    mutating func setStartDayOrNight(_ dayOrNight: DayOrNight) -> Void {
        // for a 24-hour clock, this method has no effect
        guard self.clockType == ClockType.twelveHourClock else { return }
        // don't bother doing anything if there is no change
        guard dayOrNight != self.startTime.amORpm else { return }
        
        // OK. change from am to pm or vice versa
        let newHours = self.startTime.hour + 12
        self.startTime.setHours(newHours)
    }
    
    mutating func setFinishDayOrNight(_ dayOrNight: DayOrNight) -> Void {
        // for a 24-hour clock, this method has no effect
        guard self.clockType == ClockType.twelveHourClock else { return }
        // don't bother doing anything if there is no change
        guard dayOrNight != self.startTime.amORpm else { return }
        
        // OK. change from am to pm or vice versa
        let newHours = self.startTime.hour + 12
        self.finishTime.setHours(newHours)
    }
  
    //TODO: find out what these hour clock models are doing before importing them from the other project
//    mutating func setInitialDuration(minutes: Int) {
//        let safeMinutes = SingleHand12HourClockModel.convertMinutesToSafeMinutes(CGFloat(minutes), clockType: self.clockType)
//        let newQuadrant = ClockQuadrant.mapMinutesToQuandrant(safeMinutes, clockType: self.clockType)
//        self.finishTime.quadrant = newQuadrant
//        self.finishTime.minutes = CGFloat(minutes)
//        if (minutes >= oneRotation) {
//            self.advanceRotationCountIfAllowed()
//        }
//    }
    
    static func convertMinutesToSafeMinutes(_ unsafeMinutes: CGFloat, clockType: ClockType) -> CGFloat {
        let oneRotation = 60 * clockType.rawValue
        var safeMinutes = unsafeMinutes.truncatingRemainder(dividingBy: CGFloat(oneRotation))
        if (safeMinutes < 0) {
            safeMinutes = CGFloat(oneRotation) + safeMinutes
        }
        return safeMinutes
    }
    
    internal mutating func changeRotationCountIfNeeded(_ oldTimeRange: CGFloat, newTimeRange: CGFloat) {
        
        // the arc between start and finish is almost a complete circle, then changes over to a small circle
        if ((oldTimeRange > CGFloat(almostFullRotation)) && (oldTimeRange < CGFloat(oneRotation)) && (newTimeRange >= 0) && (newTimeRange <= 60.0)) {
            self.advanceRotationCountIfAllowed()
        }
            // the arc between start and finish is almost zero, then changes over to an almost complete small circle
        else if ((newTimeRange > 640.0) && (newTimeRange < CGFloat(oneRotation)) && (oldTimeRange >= 0) && (oldTimeRange <= 60.0)) {
            self.clockRotationCount.decrementCount()
        }
    }
    
    
    var test_startTimeOfDayModel: TimeOfDayModel {
        return self.startTime
    }
    
    var test_finishTimeOfDayModel: TimeOfDayModel {
        return self.finishTime
    }
}
