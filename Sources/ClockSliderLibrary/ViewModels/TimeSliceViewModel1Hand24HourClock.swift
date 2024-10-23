//
//  SingleHand24HourClockModel.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//


import Foundation

struct TimeSliceViewModel1Hand24HourClock : TimeSliceViewModelProtocol, TimeSlice1HandClockProtocol, TimeSlice24HourClockProtocol {
    
    internal var startTime: TimeOfDayModel = TimeOfDayModel()
    internal var finishTime: TimeOfDayModel = TimeOfDayModel()
    internal var clockRotationCount: ClockRotationCount = ClockRotationCount.first
    var maximumTimeDuration: Int?
    
    var clockType: ClockType = ClockType.twentyFourHourClock
}

