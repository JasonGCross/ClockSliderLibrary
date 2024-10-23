//
//  SingleHand12HourClockModel.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//


import Foundation

struct TimeSliceViewModel1Hand12HourClock : TimeSliceViewModelProtocol, TimeSlice1HandClockProtocol {
    
    internal var startTime: TimeOfDayModel = TimeOfDayModel()
    internal var finishTime: TimeOfDayModel = TimeOfDayModel()
    internal var clockRotationCount: ClockRotationCount = ClockRotationCount.first
    var maximumTimeDuration: Int?
    
    var clockType: ClockType = ClockType.twelveHourClock
    
    mutating func advanceRotationCountIfAllowed() {}
    
    mutating func incrementDuration(minutes: Int) {
        self.finishTimeInMinutes = minutes
    }
}

