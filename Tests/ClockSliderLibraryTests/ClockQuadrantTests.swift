//
//  ClockQuadrantTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct ClockQuadrantTests {
    @Test
    func validateInstantiation() throws {
        let clockQuandrant1 = ClockQuadrant.first
        #expect(clockQuandrant1.rawValue == "first")
        
        let clockQuandrant2 = ClockQuadrant.second
        #expect(clockQuandrant2.rawValue == "second")
        
        let clockQuandrant3 = ClockQuadrant.third
        #expect(clockQuandrant3.rawValue == "third")
        
        let clockQuandrant4 = ClockQuadrant.fourth
        #expect(clockQuandrant4.rawValue == "fourth")
        
        let clockQuadrant5 = ClockQuadrant(rawValue: "fifth")
        #expect(nil == clockQuadrant5)
    }
    
    @Test(arguments: [
        (x: 1.0,   y: 1.0,   expectedResult: ClockQuadrant.first.rawValue),
        (x: -1.0,  y: 1.0,   expectedResult: ClockQuadrant.fourth.rawValue),
        (x: 1.0,   y: -1.0,  expectedResult: ClockQuadrant.second.rawValue),
        (x: -1.0,  y: -1.0,  expectedResult: ClockQuadrant.third.rawValue),
    ]) func validateMappingPointToQuadrant(
        tuple: (x: CGFloat, y: CGFloat, expectedResult: String)
    ) {
        let point = CGPoint(x: tuple.x, y: tuple.y)
        let result = ClockQuadrant.mapPointToQuadrant(point)
        #expect(result.rawValue == tuple.expectedResult)
    }
    
    @Test(arguments:[
        // 12-hour clock
        (hours: 0  ,min: 13, expectedResult: ClockQuadrant.first.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hours: 2  ,min: 21, expectedResult: ClockQuadrant.first.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hours: 5  ,min: 33, expectedResult: ClockQuadrant.second.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hours: 3  ,min: 1,  expectedResult: ClockQuadrant.second.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hours: 6  ,min: 13, expectedResult: ClockQuadrant.third.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hours: 8  ,min: 21, expectedResult: ClockQuadrant.third.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hours: 9  ,min: 0,  expectedResult: ClockQuadrant.fourth.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hours: 11 ,min: 59, expectedResult: ClockQuadrant.fourth.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        // 24-hour clock
        (hours: 0  ,min: 13, expectedResult: ClockQuadrant.first.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 5  ,min: 21, expectedResult: ClockQuadrant.first.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 6  ,min: 33, expectedResult: ClockQuadrant.second.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 11 ,min: 59, expectedResult: ClockQuadrant.second.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 12 ,min: 13, expectedResult: ClockQuadrant.third.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 13 ,min: 21, expectedResult: ClockQuadrant.third.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 22 ,min: 0,  expectedResult: ClockQuadrant.fourth.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hours: 23 ,min: 59, expectedResult: ClockQuadrant.fourth.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
    ]) func validateMappingMinutesToQuadrant(
        tuple: (hour: Int, min: Int, expectedResult: String, clockType: Int)
    ) {
        let model = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let type = ClockType(rawValue: tuple.clockType)!
        let result = ClockQuadrant.mapTimeToQuandrant(model, clockType: type)
        #expect(result.rawValue == tuple.expectedResult)
    }
}
