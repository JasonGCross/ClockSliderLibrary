//
//  ClockTypeTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct ClockTypeTests {
    @Test
    func validateInstantiation() throws {
        let clockType1 = ClockType.twelveHourClock
        #expect(clockType1.rawValue == 12)
        
        let clockType2 = ClockType.twentyFourHourClock
        #expect(clockType2.rawValue == 24)
        
        let clockType3 = ClockType(rawValue: 6)
        #expect(nil == clockType3)
    }
    
    @Test
    func validateMinutesPerRevolution() throws {
        let clockType1 = ClockType.twelveHourClock
        #expect(clockType1.minutesPerRevolution() == 720)
        
        let clockType2 = ClockType.twentyFourHourClock
        #expect(clockType2.minutesPerRevolution() == 1440)
    }
    
    @Test(arguments: [
        (clockType: ClockType.twelveHourClock.rawValue, angle: 2.0 * Double.pi, minutes: 0.0),
        (clockType: ClockType.twelveHourClock.rawValue, angle: Double.pi / 2, minutes: 180.0),
        (clockType: ClockType.twelveHourClock.rawValue, angle: Double.pi / 4, minutes: 90.0),
        (clockType: ClockType.twelveHourClock.rawValue, angle: Double.pi, minutes: 360.0),
        // twenty-four hour clock
        (clockType: ClockType.twentyFourHourClock.rawValue, angle: 2.0 * Double.pi, minutes: 0.0),
        (clockType: ClockType.twentyFourHourClock.rawValue, angle: Double.pi / 2, minutes: 360.0),
        (clockType: ClockType.twentyFourHourClock.rawValue, angle: Double.pi / 4, minutes: 180.0),
        (clockType: ClockType.twentyFourHourClock.rawValue, angle: Double.pi, minutes: 720.0)
    ])
    func validateAngleConversion(
        tuple: (clockType: Int, angle: Double, minutes: Double)
    ) {
        let clockType1 = ClockType(rawValue: tuple.clockType)!
        let angle = tuple.angle
        let result = clockType1.minutesFromAngle(angle)
        #expect(result == tuple.minutes)
    }
}
