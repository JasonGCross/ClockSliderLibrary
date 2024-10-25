//
//  TimeSliceViewModelTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Testing
import Foundation
@testable import ClockSliderLibrary

@Suite struct TimeSliceViewModelTests {
    
    @Test(arguments: [
        (hour: 0, min: 0, changedTotalMinutes: 0,  expectedHour: 0, expectedMin: 0),
        (hour: 3, min: 0, changedTotalMinutes: 183,  expectedHour: 3, expectedMin: 3),
        (hour: 15, min: 0, changedTotalMinutes: 183,  expectedHour: 15, expectedMin: 3),
        (hour: 23, min: 59, changedTotalMinutes: 2,  expectedHour: 0, expectedMin: 2),
        (hour: 0, min: 2, changedTotalMinutes: 1439,  expectedHour: 23, expectedMin: 59),
        (hour: 5, min: 15, changedTotalMinutes: 320,  expectedHour: 5, expectedMin: 20),
        (hour: 17, min: 15, changedTotalMinutes: 320,  expectedHour: 17, expectedMin: 20),
        (hour: 22, min: 15, changedTotalMinutes: 695,   expectedHour: 23, expectedMin: 35),
    ]) func validateAdjustingMinutes(
        tuple: (hour: Int, min: Int, changedTotalMinutes: Int, expectedHour: Int, expectedMin: Int)
    ) {
        var timeModel = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        timeModel.adjustMinutesSlightly(newTotalMinutes: tuple.changedTotalMinutes)
        #expect(timeModel.hour == tuple.expectedHour)
        #expect(timeModel.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        // starting at top of the clock, no overlap upon dragging
        (startHour: 0, startMin: 0, changedStartTime: 0,   expectedHour: 0, expectedMin: 0),
        (startHour: 0, startMin: 0, changedStartTime: 60,  expectedHour: 1, expectedMin: 0),
        (startHour: 0, startMin: 0, changedStartTime: 145, expectedHour: 2, expectedMin: 25),
        // starting between 9am and noon, no overlap upon dragging
        (startHour: 22, startMin: 15, changedStartTime: 695,  expectedHour: 23, expectedMin: 35),
        // other test data as in validateAdjustingMinutes
        (startHour: 3,  startMin: 0,  changedStartTime: 183,  expectedHour: 3, expectedMin: 3),
        (startHour: 15, startMin: 0,  changedStartTime: 183,  expectedHour: 15, expectedMin: 3),
        (startHour: 23, startMin: 59, changedStartTime: 2,    expectedHour: 0, expectedMin: 2),
        (startHour: 0,  startMin: 2,  changedStartTime: 1439, expectedHour: 23, expectedMin: 59),
        (startHour: 5,  startMin: 15, changedStartTime: 320,  expectedHour: 5, expectedMin: 20),
        (startHour: 17, startMin: 15, changedStartTime: 320,  expectedHour: 17, expectedMin: 20),
//        (startHour: 22, startMin: 15, changedStartTime: 695,  expectedHour: 23, expectedMin: 35),
    ]) func validateSettingStartTime(
        tuple: (startHour: Int, startMin: Int, changedStartTime: Int, expectedHour: Int, expectedMin: Int)
    ) throws {
        let startTime = TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin)
        var viewModel = TimeSliceViewModel(
            clockType: .twelveHourClock,
            startTime: startTime)
        viewModel.changeStartTimeOfDayUsingClockFaceTime(tuple.changedStartTime)
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(viewModel.startTime == expectedResult)
    }
    
    @Test(arguments: [
        (finishHour: 0,  finishMin: 0,  changedFinishTime: 0,     expectedHour: 0,  expectedMin: 0),
        (finishHour: 6,  finishMin: 0,  changedFinishTime: 360,   expectedHour: 6,  expectedMin: 0),
        (finishHour: 3,  finishMin: 0,  changedFinishTime: 240,   expectedHour: 4,  expectedMin: 0),
        (finishHour: 3,  finishMin: 0,  changedFinishTime: 325,   expectedHour: 5,  expectedMin: 25),
        (finishHour: 15, finishMin: 0,  changedFinishTime: 183,   expectedHour: 15, expectedMin: 3),
        (finishHour: 23, finishMin: 59, changedFinishTime: 2,     expectedHour: 0,  expectedMin: 2),
        (finishHour: 0,  finishMin: 2,  changedFinishTime: 1439,  expectedHour: 23, expectedMin: 59),
        (finishHour: 5,  finishMin: 15, changedFinishTime: 320,   expectedHour: 5,  expectedMin: 20),
        (finishHour: 17, finishMin: 15, changedFinishTime: 320,   expectedHour: 17, expectedMin: 20),
        (finishHour: 22, finishMin: 15, changedFinishTime: 695,   expectedHour: 23, expectedMin: 35),
    ]) func validateSettingFinishTime(
        tuple: (finishHour: Int, finishMin: Int, changedFinishTime: Int, expectedHour: Int, expectedMin: Int)
    ) throws {
        let finishTime = TimeOfDayModel(hour: tuple.finishHour, minute: tuple.finishMin)
        var viewModel = TimeSliceViewModel(
            clockType: .twelveHourClock,
            finishTime: finishTime)
        viewModel.changeFinishTimeOfDayUsingClockFaceTime(tuple.changedFinishTime)
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(viewModel.finishTime == expectedResult)
    }
}
