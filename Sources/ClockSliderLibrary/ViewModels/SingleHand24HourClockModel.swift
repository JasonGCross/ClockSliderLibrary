//
//  SingleHand24HourClockModel.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//


import Foundation

struct SingleHand24HourClockModel : TimeRangeSliderControlViewModelProtocol, SingleHandedClockModelProtocol, TwentyFourHourClockModelProtocol {
    
    internal var startTime: TimeOfDayModel = TimeOfDayModel()
    internal var finishTime: TimeOfDayModel = TimeOfDayModel()
    internal var clockRotationCount: ClockRotationCount = ClockRotationCount.first
    var maximumTimeDuration: Int?
    
    var clockType: ClockType = ClockType.twentyFourHourClock
}

