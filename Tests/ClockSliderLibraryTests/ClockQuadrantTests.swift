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
        let clockQuandrant1 = ClockQuadrantModel.first
        #expect(clockQuandrant1.rawValue == "first")
        
        let clockQuandrant2 = ClockQuadrantModel.second
        #expect(clockQuandrant2.rawValue == "second")
        
        let clockQuandrant3 = ClockQuadrantModel.third
        #expect(clockQuandrant3.rawValue == "third")
        
        let clockQuandrant4 = ClockQuadrantModel.fourth
        #expect(clockQuandrant4.rawValue == "fourth")
        
        let clockQuadrant5 = ClockQuadrantModel(rawValue: "fifth")
        #expect(nil == clockQuadrant5)
    }
    
    @Test(arguments: [
        (x: 1.0,   y: 1.0,   expectedResult: ClockQuadrantModel.first.rawValue),
        (x: -1.0,  y: 1.0,   expectedResult: ClockQuadrantModel.fourth.rawValue),
        (x: 1.0,   y: -1.0,  expectedResult: ClockQuadrantModel.second.rawValue),
        (x: -1.0,  y: -1.0,  expectedResult: ClockQuadrantModel.third.rawValue),
    ]) func validateMappingPointToQuadrant(
        tuple: (x: CGFloat, y: CGFloat, expectedResult: String)
    ) {
        let point = CGPoint(x: tuple.x, y: tuple.y)
        let result = ClockQuadrantModel.mapPointToQuadrant(point)
        #expect(result.rawValue == tuple.expectedResult)
    }
    
    @Test(arguments:[
        // 12-hour clock
        (hour: 0  ,min: 13, expectedResult: ClockQuadrantModel.first.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hour: 2  ,min: 21, expectedResult: ClockQuadrantModel.first.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hour: 5  ,min: 33, expectedResult: ClockQuadrantModel.second.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hour: 3  ,min: 1,  expectedResult: ClockQuadrantModel.second.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hour: 6  ,min: 13, expectedResult: ClockQuadrantModel.third.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hour: 8  ,min: 21, expectedResult: ClockQuadrantModel.third.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        (hour: 9  ,min: 0,  expectedResult: ClockQuadrantModel.fourth.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        (hour: 11 ,min: 59, expectedResult: ClockQuadrantModel.fourth.rawValue, clockType: ClockType.twelveHourClock.rawValue),
        // 24-hour clock
        (hour: 0  ,min: 13, expectedResult: ClockQuadrantModel.first.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 5  ,min: 21, expectedResult: ClockQuadrantModel.first.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 6  ,min: 33, expectedResult: ClockQuadrantModel.second.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 11 ,min: 59, expectedResult: ClockQuadrantModel.second.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 12 ,min: 13, expectedResult: ClockQuadrantModel.third.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 13 ,min: 21, expectedResult: ClockQuadrantModel.third.rawValue,  clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 22 ,min: 0,  expectedResult: ClockQuadrantModel.fourth.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        (hour: 23 ,min: 59, expectedResult: ClockQuadrantModel.fourth.rawValue, clockType: ClockType.twentyFourHourClock.rawValue),
        // greater than one rotation
        (hour: 24  ,min: 13, expectedResult: ClockQuadrantModel.first.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
        // negative minutes
        (hour: 0  ,min: -5, expectedResult: ClockQuadrantModel.fourth.rawValue,  clockType: ClockType.twelveHourClock.rawValue),
    ]) func validateMappingMinutesToQuadrant(
        tuple: (hour: Int, min: Int, expectedResult: String, clockType: Int)
    ) {
        let model = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let type = ClockType(rawValue: tuple.clockType)!
        let result = ClockQuadrantModel.mapTimeToQuandrant(model, clockType: type)
        #expect(result.rawValue == tuple.expectedResult)
    }
}

/*

@Test func validateMapPointToQuadrant() async throws {
    let point = CGPoint(x: 1.0, y: 1.0)
    let result = ClockQuadrant.mapPointToQuadrant(point)
    let expected = ClockQuadrant.first
    #expect(result == expected)
}

    @Test func validateMapTimeToQuandrant() async throws {
        let model = TimeOfDayModel(hour: 0, minute: 13)
        let type = ClockType.twelveHourClock
        let result = ClockQuadrant.mapTimeToQuandrant(model, clockType: type)
        let expected = ClockQuadrant.first
        #expect(result == expected)
    }

*/



