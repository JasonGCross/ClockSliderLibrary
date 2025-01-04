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
public struct TimeSliceViewModel {
    
    
    /*
     *-------------------------------------------------=------------------------------------------------+
     *                                                 :                                                =
     *                                                 =                                                =
     *                                                 .                                                =
     *                                                 -                                                =
     *                                                 =                                                =
     *                                       .:----------------:.                                       =
     *                                 .:---:.         -        .:----.                                 =
     *                              :--:               -              .---.                             =
     *                           ---                   .                  :--.                          =
     *                        .=-                      =               :-----+*-                        =
     *                      :-:                        -             :+=      =-+=                      =
     *                    :=.                          .            :=  --. =-   +=-                    =
     *                  .+:                   :------::+:------:    +     *@:    .- +:                  =
     *                 :=                 :--:.        -        :--:-=  :=. .--  =.  :=                 =
     *                =:               .=-.            .            -*+=.      =+:    .+                =
     *               +:              :-:               =              :=+-::::--        +.              =
     *              +.             .+:                 :            -   .=:              +              =
     *             -.             --                   .          .       :=              +             =
     *             =             -:                    =        ..         .+             :-            =
     *            +             --                     :       .            .+             *            =
     *           .+            :=                      :                     .+            :=           =
     *           =:            *                       =     .                +.            *           =
     *           *            .=                       .   -                  .-            *           =
     *           *            -:                       : :                     +            =.          =
     *           *            -:                       +                       =            =.          =
     *           *            :-                                               =            +.          =
     *           +             *                                              -:            *           =
     *           :-            =.                                             *             +           =
     *            *             *                                            +.            =.           =
     *            :-             *                                          +:             +            =
     *             +              =                                        =.             =             =
     *             .+              =-                                    .+.             :-             =
     *              :+              .=:                                .=-              -=              =
     *               .+               .=-                            :=:               =-               =
     *                 =                 ---.                     :--.                =:                =
     *                  =-                  :---:.           :---:                  .+                  =
     *                   .=:                     .:::::::::::                      =-                   =
     *                     :=:                                                  .--                     =
     *                       .=:                                              .=-                       =
     *                         .--:                                        .--:                         =
     *                            .---                                  :--:                            =
     *                                :---:                        .----.                               =
     *                                    .:-----::..     ..:------.                                    =
     *                                            ...:::::..                                            =
     *                                                                                                  =
     *                                                                                                  =
     *                                                                                                  =
     *                                                                                                  =
     #..................................................................................................+

     The above ASCII art depicts two concentric cirles, with an arc.
     The outermost "ring" is a slider, along which a round thumb (circle) is dragged.
     There are actually two thumbs but only one is shown.
     Some clocks allow for setting start and finish.
     Other clocks always lock the start time to the top of the clock and allow only changing the finish.
     The inner ring is a clock face.
     The arc is an example angle drawn, using as an origin the centre of the clock face.
     Along the arc a thumb is drawn, with an attempt to draw cross hairs and a centre point in the thumb.
     
     There are a number of conversions that need to happen from the user dragging his thumb / mouse,
     to the time span represented by the arc between the start thumb and the finish thumb.
     
     1. Screen Point:  e.g. (x=200, y=75)
     The user's drag is reported in absolute screen coordinates.
     
     2. Slider Centre Point: e.g. (x=60, y=60)
     The screen point is converted to a point along the centre of the slider track,
     using the centre of the clock face as (0,0) instead of the view's upper left corner.
     
     3. Angle: e.g. 0.785 radians
     The point in the centre of the slider track is converted to an angle,
     the angle between the vertical line (12 o'clock) and the intercept to the slider centre point.
     
     4. Raw Minutes on Clock Face: e.g. 90 minutes
     The angle is converted to raw minutes which the hour hand should lie on the clock face.
     This position of the hour hand is different between 12-hour clocks and 24-hour clocks.
     For 12-hour clocks, this time can only be a number between 0 minutes and 720 minutes (12 * 60).
     Both AM and PM will show the same clock face time.
     
     5. Time of Day Time: e.g. 1:30pm, or 13:30 = 810 minutes
     For a 24-hour clock, the time of day is always the same as the clock face time.
     But for a 12-hour clock, the time of day is only the same as the clock face time before noon.
     After noon, the actual time of day is 12 hours greater.
     For example, 1:30 on the clock is 13:30 of actual time.
     In order to perform this calculation, more than just the Clock Face Time and clock type are
     needed. The old time of day is also needed as it must be determined if a change from am to pm
     is required or not.
     */
    
    //MARK:- properties
    // these 2 properties replace having 4 different subclasses
    var startTimeIsFixedToZero: Bool = false
    var clockType: ClockType = ClockType.twelveHourClock
    
    var startTime: TimeOfDayModel = TimeOfDayModel()
    var finishTime: TimeOfDayModel = TimeOfDayModel()
    
    /// helps distinguish between the first and second rotation around the clock
    var clockRotationCount: ClockRotationCount = ClockRotationCount.first
    var maximumTimeDuration: Int?
    
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
    var almostFullRotation: Int { self.clockType.rawValue * 60 * 640 / 720 }
    
    var timeRange: Int {
        get {
            var selectedTime: Int = TimeSliceViewModel.timeSpanBetween(
                self.startTime,
                finishTime: self.finishTime)
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
    
    var numberOfMinutesPerClockRotation: Int {
        return 60 * self.clockType.rawValue
    }
    
    var maxAllowedMinutes: Int { self.clockType.rawValue * 60 }
    
    //MARK:- constructor
    init(startTimeIsFixedToZero: Bool = false,
         clockType: ClockType = ClockType.twelveHourClock,
         startTime: TimeOfDayModel = TimeOfDayModel(),
         finishTime: TimeOfDayModel = TimeOfDayModel(),
         clockRotationCount: ClockRotationCount = ClockRotationCount.first,
         maximumTimeDuration: Int? = nil
    ) {
        self.startTimeIsFixedToZero = startTimeIsFixedToZero
        self.clockType = clockType
        self.startTime = startTime
        self.finishTime = finishTime
        self.clockRotationCount = clockRotationCount
        self.maximumTimeDuration = maximumTimeDuration
    }
    
    //MARK:- functions
    func changeTimeOfDayUsingClockFaceTime(oldTimeOfDay: TimeOfDayModel, clockFaceTime newMinutes: Int) -> TimeOfDayModel {
        guard self.clockType != ClockType.twentyFourHourClock else {
            let newValue = TimeOfDayModel.timeModelFromMinutes(newMinutes)
            return newValue
        }
        
        // now guaranteed to be working with a 12-hour clock
        let safeMinutes = TimeSliceViewModel.convertMinutesToSafeMinutes(newMinutes, clockType: self.clockType)
        
        // this is the value which will be returned
        var newTimeOfDay: TimeOfDayModel = oldTimeOfDay
        
        // decide whether or not this single hand represents daytime or night time
        // note that this decision depends explicitly on the 12 o'clock position
        // rather than compare quadrants, make sure the new time is close to the old time
        newTimeOfDay.adjustMinutesSlightly(newTotalMinutes: safeMinutes)        
        return newTimeOfDay
    }
    
    mutating func changeStartTimeOfDayUsingClockFaceTime(_ minutes: Int) {
        guard false == self.startTimeIsFixedToZero else { return }
        let newValue = self.changeTimeOfDayUsingClockFaceTime(oldTimeOfDay: self.startTime, clockFaceTime: minutes)
        self.startTime = newValue
    }
    
    mutating func changeFinishTimeOfDayUsingClockFaceTime(_ minutes: Int) {
        let newValue = self.changeTimeOfDayUsingClockFaceTime(oldTimeOfDay: self.finishTime, clockFaceTime: minutes)
        self.finishTime = newValue
    }
    
    static func timeSpanBetween(_ startTime: TimeOfDayModel, finishTime:TimeOfDayModel) -> Int {
        // we cannot just perform simple subtraction because we are dealing with a clock
        // meaning from 11:00pm to 3:00am crosses the day boundary,
        // which must be taken into account
        
        let calendar: Calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        var startTimeComponents = DateComponents()
        var finishTimeComponents = DateComponents()
        startTimeComponents.hour = startTime.hour
        startTimeComponents.minute = startTime.minute
        finishTimeComponents.hour = finishTime.hour
        finishTimeComponents.minute = finishTime.minute
        
        guard let startTimeDateObject = calendar.date(from: startTimeComponents),
            var finishTimeDateObject = calendar.date(from: finishTimeComponents) else {
                return 0
        }
        
        // have we taken into account the "crossing-midnight-boundary" issue yet?
        if (finishTimeDateObject < startTimeDateObject) {
            // add another 12 hours to the finish
            guard nil != finishTimeComponents.hour else {
                return 0
            }
            finishTimeComponents.hour! += 24
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
        guard dayOrNight != self.finishTime.amORpm else { return }
        
        // OK. change from am to pm or vice versa
        let newHours = self.finishTime.hour + 12
        self.finishTime.setHours(newHours)
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
}


