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
        // starting at top of the clock, no overlap upon dragging
//        (startHour: 0, startMin: 0, finishHour: 6, finishMin: 0, changedStartTime: 0,   expectedHour: 0, expectedMin: 0),
        (startHour: 0, startMin: 0, finishHour: 3, finishMin: 0, changedStartTime: 60,  expectedHour: 1, expectedMin: 0),
//        (startHour: 0, startMin: 0, finishHour: 3, finishMin: 0, changedStartTime: 145, expectedHour: 2, expectedMin: 25),
//      // starting between 9am and noon, no overlap upon dragging
//        (startHour: 22, startMin: 15, finishHour: 2, finishMin: 37, changedStartTime: 1415,   expectedHour: 23, expectedMin: 35),
    ]) func validateSettingStartTime(
        tuple: (startHour: Int, startMin: Int, finishHour: Int, finishMin: Int, changedStartTime: Int, expectedHour: Int, expectedMin: Int)
    ) throws {
        let startTime = TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin)
        let finishTime = TimeOfDayModel(hour: tuple.finishHour, minute: tuple.finishMin)
        
        withKnownIssue {
            var viewModel = TimeSliceViewModel(
                startTime: startTime,
                finishTime: finishTime)
            //        viewModel.startTimeInMinutes = tuple.changedStartTime
            let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
            #expect(viewModel.startTime == expectedResult)
        }
    }
    
    @Test(arguments: [
        (startHour: 0, startMin: 0, finishHour: 6, finishMin: 0, changedFinishTime: 0,   expectedHour: 6, expectedMin: 0),
//        (startHour: 0, startMin: 0, finishHour: 3, finishMin: 0, changedFinishTime: 60,  expectedHour: 4, expectedMin: 0),
//        (startHour: 0, startMin: 0, finishHour: 3, finishMin: 0, changedFinishTime: 145, expectedHour: 5, expectedMin: 25),
        
        //TODO: add many more cases, account for crossing the 12-hour mark, and also having start/finish on either side of it
    ]) func validateSettingFinishTime(
        tuple: (startHour: Int, startMin: Int, finishHour: Int, finishMin: Int, changedStartTime: Int, expectedHour: Int, expectedMin: Int)
    ) throws {
        let startTime = TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin)
        let finishTime = TimeOfDayModel(hour: tuple.finishHour, minute: tuple.finishMin)
        
        withKnownIssue {
            var viewModel = TimeSliceViewModel(
                startTime: startTime,
                finishTime: finishTime)
            //        viewModel.finishTimeInMinutes = tuple.changedStartTime
            let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
            #expect(viewModel.finishTime == expectedResult)
        }
    }
}
