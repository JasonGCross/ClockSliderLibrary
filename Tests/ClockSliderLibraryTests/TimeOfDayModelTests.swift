//
//  TimeOfDayModelTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Testing
import Foundation
@testable import ClockSliderLibrary

@Suite struct TimeOfDayModelTests {
    
    @Test(arguments: [
        // no overflow
        (hour: 0,  min: 0,  expectedHour: 0,  expectedMin: 0),
        (hour: 0,  min: 1,  expectedHour: 0,  expectedMin: 1),
        (hour: 5,  min: 1,  expectedHour: 5,  expectedMin: 1),
        // overflow
        (hour: 0,  min: 62, expectedHour: 1,  expectedMin: 2),
        (hour: 25, min: 0,  expectedHour: 1,  expectedMin: 0),
        (hour: 3,  min: 66, expectedHour: 4,  expectedMin: 6),
        // negative minutes
        (hour: 0,   min: -1,   expectedHour: 23, expectedMin: 59),
        (hour: 1,   min: -50,  expectedHour: 0,  expectedMin: 10),
        (hour: -45, min: 48,   expectedHour: 3,  expectedMin: 48),
        // days of overflow
        (hour: 72,  min: 0,    expectedHour: 0,  expectedMin: 0),
        (hour: -48, min: 1,    expectedHour: 0,  expectedMin: 1),
        (hour: 0,   min: 2829, expectedHour: 23, expectedMin: 9),
        (hour: 23,  min: 61,   expectedHour: 0,  expectedMin: 1),
//        (hour: 0,   min: -1,   expectedHour: 23, expectedMin: 59),
    ]) func validateConstruction(
        tuple: (hour: Int, min: Int, expectedHour: Int, expectedMin: Int)
    ) {
        let model = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        #expect(model.hour == tuple.expectedHour)
        #expect(model.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        (hour: 0,  min: 0,  expectedResult: DayOrNight.am.rawValue),
        (hour: 11,  min: 59,  expectedResult: DayOrNight.am.rawValue),
        (hour: 12,  min: 0,  expectedResult: DayOrNight.pm.rawValue),
        (hour: 23,  min: 59,  expectedResult: DayOrNight.pm.rawValue),
        (hour: 0,   min: -1,  expectedResult: DayOrNight.pm.rawValue),
        (hour: 6,  min: 0,  expectedResult: DayOrNight.am.rawValue),
        (hour: 17,  min: 0,  expectedResult: DayOrNight.pm.rawValue),
    ])
    func validateAmOrPm(
        tuple: (hour: Int, min: Int, expectedResult: String)
    ) {
        let model = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        #expect(model.amORpm.rawValue == tuple.expectedResult)
    }
    
    @Test(arguments: [
        (hour1: 0, min1: 0, hour2: 0, min2: 0, expectedResult: true),
        (hour1: 23, min1: 59, hour2: 23, min2: 59, expectedResult: true),
        (hour1: 0, min1: 0, hour2: 22, min2: 45, expectedResult: false),
        (hour1: 0, min1: 60, hour2: 1, min2: 0, expectedResult: true),
    ]) func validateEquality(
        tuple: (hour1: Int, min1: Int, hour2: Int, min2: Int, expectedResult: Bool)
    ) {
        let model1 = TimeOfDayModel(hour: tuple.hour1, minute: tuple.min1)
        let model2 = TimeOfDayModel(hour: tuple.hour2, minute: tuple.min2)
        if tuple.expectedResult {
            #expect(model1 == model2)
        }
        else {
            #expect(model1 != model2)
        }
    }
    
    @Test() func validateNow() {
        let model = TimeOfDayModel.now
        #expect(model.hour >= 0 && model.hour <= 23)
        #expect(model.minute >= 0 && model.minute <= 59)
        
        let nowDate = Date()
        let calendar = Calendar(identifier: .gregorian)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: nowDate)
        #expect(abs(model.hour - nowComponents.hour!) <= 1)
        #expect(abs(model.minute - nowComponents.minute!) <= 1)
    }
    
    @Test(arguments:[
        // no overflow
        (hour: 0,  min: 0,  expectedHour: 0,  expectedMin: 0),
        (hour: 0,  min: 1,  expectedHour: 0,  expectedMin: 1),
        (hour: 5,  min: 1,  expectedHour: 5,  expectedMin: 1),
        // overflow
        (hour: 0,  min: 62, expectedHour: 1,  expectedMin: 2),
        (hour: 25, min: 0,  expectedHour: 1,  expectedMin: 0),
        (hour: 3,  min: 66, expectedHour: 4,  expectedMin: 6),
        // negative minutes
        (hour: 0,   min: -1,   expectedHour: 23, expectedMin: 59),
        (hour: 1,   min: -50,  expectedHour: 0,  expectedMin: 10),
        (hour: -45, min: 48,   expectedHour: 3,  expectedMin: 48),
        // days of overflow
        (hour: 72,  min: 0,    expectedHour: 0,  expectedMin: 0),
        (hour: -48, min: 1,    expectedHour: 0,  expectedMin: 1),
        (hour: 0,   min: 2829, expectedHour: 23, expectedMin: 9),
        (hour: 23,  min: 61,   expectedHour: 0,  expectedMin: 1),
    ])
    func validateConversionToFoundationDate(
        tuple: (hour: Int, min: Int, expectedHour: Int, expectedMin: Int)
    ) {
        let model = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let date = model.getFoundationDateWithOnlyHoursAndMinutes()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: date)
        #expect(components.hour! == tuple.expectedHour)
        #expect(components.minute! == tuple.expectedMin)
    }
    
    @Test(arguments: [
        // no overflow
        (initialHour: 0,  initialMin: 0,  setMin: 10    ,expectedHour: 0  ,expectedMin: 10 ),
        // overflow
        (initialHour: 0,  initialMin: 0,  setMin: 60    ,expectedHour: 1  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 0,  setMin: 75    ,expectedHour: 1  ,expectedMin: 15),
        (initialHour: 23, initialMin: 59, setMin: 2     ,expectedHour: 23  ,expectedMin: 2 ),
        // negative minutes
        (initialHour: 0,  initialMin: 0,  setMin: -10   ,expectedHour: 23 ,expectedMin: 50),
        // days of overflow
        (initialHour: 0,  initialMin: 0,  setMin: 1440  ,expectedHour: 0  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 0,  setMin: 1441  ,expectedHour: 0  ,expectedMin: 1 ),
        (initialHour: 23, initialMin: 59, setMin: 2880  ,expectedHour: 23 ,expectedMin: 0),
         (initialHour: 23, initialMin: 59, setMin: 2882  ,expectedHour: 23  ,expectedMin: 2 ),
        (initialHour: 0,  initialMin: 0,  setMin: -1441 ,expectedHour: 23 ,expectedMin: 59),
    ])
    func setMinutes(
        tuple: (initialHour: Int, initialMin: Int, setMin: Int, expectedHour: Int, expectedMin: Int)
    ) {
        var timeOnly = TimeOfDayModel(hour: tuple.initialHour, minute: tuple.initialMin)
        timeOnly.setMinutes(tuple.setMin)
        #expect(timeOnly.hour == tuple.expectedHour)
        #expect(timeOnly.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        // no overflow
        (initialHour: 0, initialMin: 0,   setHour: 10    ,expectedHour: 10 ,expectedMin: 0),
        // days of overflow
        (initialHour: 0,  initialMin: 0,  setHour: 24  ,expectedHour: 0  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 1,  setHour: 25  ,expectedHour: 1  ,expectedMin: 1 ),
        (initialHour: 23, initialMin: 59, setHour: 48  ,expectedHour: 0  ,expectedMin: 59),
        (initialHour: 0,  initialMin: 59, setHour: 47  ,expectedHour: 23 ,expectedMin: 59),
        (initialHour: 11, initialMin: 0,  setHour: -24 ,expectedHour: 0 ,expectedMin: 0),
    ])
    func setHours(
        tuple: (initialHour: Int, initialMin: Int, setHour: Int, expectedHour: Int, expectedMin: Int)
    ) {
        var timeOnly = TimeOfDayModel(hour: tuple.initialHour, minute: tuple.initialMin)
        timeOnly.setHours(tuple.setHour)
        #expect(timeOnly.hour == tuple.expectedHour)
        #expect(timeOnly.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        // no overflow
        (hour: 0, min: 0, add: 0, expectedHour: 0, expectedMin: 0),
        (hour: 0, min: 1, add: 1, expectedHour: 0, expectedMin: 2),
        // overflow
        (hour: 0, min: 1, add: 61, expectedHour: 1, expectedMin: 2),
        (hour: 0, min: 0, add: 60, expectedHour: 1, expectedMin: 0),
        (hour: 3, min: 3, add: 63, expectedHour: 4, expectedMin: 6),
        // negative minutes
        (hour: 0, min: 0, add: -1, expectedHour: 23, expectedMin: 59),
        (hour: 0, min: 30, add: -20, expectedHour: 0, expectedMin: 10),
        (hour: 3, min: 0, add: -90, expectedHour: 1, expectedMin: 30),
        // days of overflow
        (hour: 0, min: 0, add: 1440, expectedHour: 0, expectedMin: 0),
        (hour: 0, min: 0, add: 1441, expectedHour: 0, expectedMin: 1),
        (hour: 23, min: 59, add: 2880, expectedHour: 23, expectedMin: 59),
        (hour: 23, min: 59, add: 2882, expectedHour: 0, expectedMin: 1),
        (hour: 0, min: 0, add: -1441, expectedHour: 23, expectedMin: 59),
    ])
    func testAddingTimeInterval(
        tuple: (hour: Int, min: Int, add: TimeInterval, expectedHour: Int, expectedMin: Int)
    ) {
        let timeOnly = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let result = timeOnly.addingTimeInterval(60 * tuple.add)
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(result == expectedResult)
    }
    
    @Test(arguments: [
        (hour1: 0,  min1: 0,  hour2: 0,  min2: 0,  expectedResult: 0),
        (hour1: 0,  min1: 1,  hour2: 0,  min2: 0,  expectedResult: 60),
        (hour1: 0,  min1: 0,  hour2: 0,  min2: 1,  expectedResult: -60),
        (hour1: 23, min1: 59, hour2: 23, min2: 59, expectedResult: 0),
        (hour1: 0,  min1: 0,  hour2: 22, min2: 45, expectedResult: -81_900),
        (hour1: 22, min1: 45, hour2: 0,  min2: 0,  expectedResult: 81_900),
        (hour1: 0,  min1: 60, hour2: 1,  min2: 0,  expectedResult: 0),
    ]) func validateTimeIntervalSince(
        tuple: (hour1: Int, min1: Int, hour2: Int, min2: Int, expectedResult: TimeInterval)
    ) {
        let model1 = TimeOfDayModel(hour: tuple.hour1, minute: tuple.min1)
        let model2 = TimeOfDayModel(hour: tuple.hour2, minute: tuple.min2)
        #expect(model1.timeIntervalSince(model2) == tuple.expectedResult)
    }
    
    @Test
    func validateTimeOnlyFromFoundationDate() {
        let date = Date()
        let model = TimeOfDayModel.timeOnlyFromFoundationDate(date)
        #expect(model.hour == Calendar.current.component(.hour, from: date))
        #expect(model.minute == Calendar.current.component(.minute, from: date))
    }
    
    @Test(arguments: [
        // no overflow
        (min: 0     ,expectedHour: 0  ,expectedMin: 0  ),
        (min: 10    ,expectedHour: 0  ,expectedMin: 10 ),
        // overflow
        (min: 60    ,expectedHour: 1  ,expectedMin: 0  ),
        (min: 75    ,expectedHour: 1  ,expectedMin: 15 ),
        (min: 1382  ,expectedHour: 23 ,expectedMin: 2  ),
        // negative minutes
        (min: -10   ,expectedHour: 23 ,expectedMin: 50 ),
        // days of overflow
        (min: 1440  ,expectedHour: 0  ,expectedMin: 0  ),
        (min: 1441  ,expectedHour: 0  ,expectedMin: 1  ),
        (min: 2820  ,expectedHour: 23 ,expectedMin: 0  ),
        (min: 2822  ,expectedHour: 23 ,expectedMin: 2  ),
        (min: -1441 ,expectedHour: 23 ,expectedMin: 59 ),
    ]) func validateTimeOnlyFromMinutes(
        tuple: (min: Int, expectedHour: Int, expectedMin: Int)
    ) {
        let result = TimeOfDayModel.timeModelFromMinutes(tuple.min)
        #expect(result.hour == tuple.expectedHour)
        #expect(result.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        (hour: 0, expectedHour: 0),
        (hour: 1, expectedHour: 1),
        (hour: 23, expectedHour: 23),
        (hour: 25, expectedHour: 1),
        (hour: 49, expectedHour: 1),
        (hour: -1, expectedHour: 23),
        (hour: -36, expectedHour: 12),
    ]) func validateTimeOnlyFromHours(
        tuple: (hour: Int, expectedHour: Int)
    ) {
        let model = TimeOfDayModel.timeOnlyFromHours(tuple.hour)
        #expect(model.hour == tuple.expectedHour)
    }
    
    @Test func validateDebugDescription() {
        let model = TimeOfDayModel(hour: 1, minute: 2)
        #expect(model.debugDescription != "")
    }
}
