//
//  ClockFaceTimeTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct ClockFaceTimeTests {
    
    
    
    @Test(
        arguments:[
        // 12-hour clock
        (hours: 0  ,min: 13, dayOrNight: "AM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "first"),
        (hours: 2  ,min: 21, dayOrNight: "AM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "first"),
        (hours: 5  ,min: 33, dayOrNight: "AM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "second"),
        (hours: 3  ,min: 1,  dayOrNight: "AM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "second"),
        (hours: 6  ,min: 13, dayOrNight: "PM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "third"),
        (hours: 8  ,min: 21, dayOrNight: "PM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "third"),
        (hours: 9  ,min: 0,  dayOrNight: "PM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "fourth"),
        (hours: 11 ,min: 59, dayOrNight: "PM", clockType: ClockType.twelveHourClock.rawValue, expectedResult: "fourth"),
        // 24-hour clock
        (hours: 0  ,min: 13, dayOrNight: "AM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "first"),
        (hours: 5  ,min: 21, dayOrNight: "AM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "first"),
        (hours: 6  ,min: 33, dayOrNight: "AM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "second"),
        (hours: 11 ,min: 59, dayOrNight: "AM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "second"),
        (hours: 12 ,min: 13, dayOrNight: "PM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "third"),
        (hours: 13 ,min: 21, dayOrNight: "PM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "third"),
        (hours: 22 ,min: 0,  dayOrNight: "PM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "fourth"),
        (hours: 23 ,min: 59, dayOrNight: "PM", clockType: ClockType.twentyFourHourClock.rawValue, expectedResult: "fourth"),
    ]
    ) func validateMappingTimeToQuadrant(
        tuple: (hours: Int, min: Int, dayOrNight: String, clockType: Int, expectedResult: String)
    ) {
        let type = ClockType(rawValue: tuple.clockType)!
        let dayOrNight = DayOrNight(rawValue: tuple.dayOrNight)!
        let totalMinutes = tuple.hours * 60 + tuple.min
        let model = ClockFaceTime(minutes: totalMinutes, amORpm: dayOrNight, clockType: type)
        
        let result = model.quadrant
        #expect(result.rawValue == tuple.expectedResult)
    }
}
