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
public protocol TimeRangeSliderControlViewModelProtocol {
    var startTime: TimeOfDayModel {get set}
    var finishTime: TimeOfDayModel {get set}
    
    /// helps distinguish between the first and second rotation around the clock
    var clockRotationCount: ClockRotationCount {get set}
    var maximumTimeDuration: Int? {get set}
    
    var startTimeInMinutes: Int {get set}
    var finishTimeInMinutes: Int {get set}
    var startDayOrNightString: String {get}
    var finishDayOrNightString: String {get}
    var timeRange: Int {get}
    
    mutating func advanceRotationCountIfAllowed()
    
    mutating func setStartDayOrNight(_ dayOrNight: DayOrNight) -> Void
    mutating func setFinishDayOrNight(_ dayOrNight: DayOrNight) -> Void
    mutating func incrementDuration(minutes: Int)
    mutating func setInitialDuration(minutes: Int)
    static func convertMinutesToSafeMinutes(_ unsafeMinutes: Int, clockType: ClockType) -> Int
    
    mutating func changeRotationCountIfNeeded(_ oldTimeRange: Int, newTimeRange: Int)
    static func timeSpanBetween(_ startTime: Int, finishTime:Int) -> Int
    
    var test_startTimeOfDayModel: TimeOfDayModel {get}
    var test_finishTimeOfDayModel: TimeOfDayModel {get}
    
    var clockType: ClockType {get}
    var oneRotation: Int {get}
    var halfRotation: Int {get}
    var quarterRotation: Int {get}
    var threeQuarterRotation: Int {get}
}

extension TimeRangeSliderControlViewModelProtocol {
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
    
    static func timeSpanBetween(_ startTime: Int, finishTime:Int) -> Int {
        // we cannot just perform simple subtraction because we are dealing with a clock
        // meaning from 11:00pm to 3:00am crosses the day boundary,
        // which must be taken into account
        
        let calendar: Calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        var startTimeComponents = DateComponents()
        var finishTimeComponents = DateComponents()
        startTimeComponents.minute = startTime
        finishTimeComponents.minute = finishTime
        
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
        let selectedTime: Int = Int(round(secondDifference / 60.0))
        
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
    
    var timeRange: Int {
        get {
            var selectedTime: Int = SingleHand12HourClockModel.timeSpanBetween(
                self.startTime.minute,
                finishTime: self.finishTime.minute)
            switch (clockRotationCount) {
            case .first:
                if (selectedTime > oneRotation) {
                    selectedTime -= oneRotation
                }
            case .second:
                if selectedTime < oneRotation {
                    selectedTime += oneRotation
                }
            }
            return selectedTime
        }
    }
  
    //TODO: find out what these hour clock models are doing before importing them from the other project
    mutating func setInitialDuration(minutes: Int) {
        let timeModel = TimeOfDayModel.timeModelFromMinutes(minutes)
        let newQuadrant = ClockQuadrant.mapTimeToQuandrant(timeModel, clockType: self.clockType)
        self.finishTime.quadrant = newQuadrant
        self.finishTime.setMinutes(minutes)
        if (minutes >= oneRotation) {
            self.advanceRotationCountIfAllowed()
        }
    }
    
    static func convertMinutesToSafeMinutes(_ unsafeMinutes: Int, clockType: ClockType) -> Int {
        let oneRotation = 60 * clockType.rawValue
        var safeMinutes = Double(unsafeMinutes).truncatingRemainder(dividingBy: CGFloat(oneRotation))
        if (safeMinutes < 0) {
            safeMinutes = CGFloat(oneRotation) + safeMinutes
        }
        return Int(safeMinutes.rounded())
    }
    
    internal mutating func changeRotationCountIfNeeded(_ oldTimeRange: Int, newTimeRange: Int) {
        
        // the arc between start and finish is almost a complete circle, then changes over to a small circle
        if ((oldTimeRange > almostFullRotation) &&
            (oldTimeRange < oneRotation) &&
            (newTimeRange >= 0) &&
            (newTimeRange <= 60)) {
            self.advanceRotationCountIfAllowed()
        }
            // the arc between start and finish is almost zero, then changes over to an almost complete small circle
        else if ((newTimeRange > almostFullRotation) &&
                 (newTimeRange < oneRotation) &&
                 (oldTimeRange >= 0) &&
                 (oldTimeRange <= 60)) {
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


