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
        let viewModel = TimeSliceViewModel(
            clockType: .twelveHourClock,
            startTime: startTime)
        viewModel.changeStartTimeOfDayUsingClockFaceTime(CGFloat(tuple.changedStartTime))
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
        let viewModel = TimeSliceViewModel(
            clockType: .twelveHourClock,
            finishTime: finishTime)
        viewModel.changeFinishTimeOfDayUsingClockFaceTime(CGFloat(tuple.changedFinishTime))
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(viewModel.finishTime == expectedResult)
    }
    
    @Test func validateVariousGettersSetters() {
        let model = TimeSliceViewModel(
            startTimeIsFixedToZero: false,
            clockType: ClockType.twelveHourClock,
            startTime: TimeOfDayModel(),
            finishTime: TimeOfDayModel(),
            clockRotationCount: ClockRotationCount.first,
            maximumTimeDuration: nil)
        
        #expect(model.startTimeIsFixedToZero == false)
        #expect(model.clockType == .twelveHourClock)
        #expect(model.startTime == TimeOfDayModel())
        #expect(model.finishTime == TimeOfDayModel())
        #expect(model.clockRotationCount == .first)
        #expect(model.maximumTimeDuration == nil)
        #expect(model.startDayOrNightString == DayOrNight.am.rawValue)
        #expect(model.finishDayOrNightString == DayOrNight.am.rawValue)
        #expect(model.oneRotation == 720)
        #expect(model.quarterRotation == 180)
        #expect(model.halfRotation == 360)
        #expect(model.threeQuarterRotation == 540)
        #expect(model.almostFullRotation == 640)
        #expect(model.timeRange == 0)
    }
    
    @Test(arguments:[
        // first rotation
        (startHour: 0,   startMin: 0, finishHour: 3,  finishMin: 0,  rotation: ClockRotationCount.first.rawValue, expectedTime: 180),
        (startHour: 17, startMin: 15, finishHour: 23, finishMin: 59, rotation: ClockRotationCount.first.rawValue, expectedTime: 404),
        (startHour: 22, startMin: 33, finishHour: 1,  finishMin: 33, rotation: ClockRotationCount.first.rawValue, expectedTime: 180),
        // selected time > one rotation (switch in code is never hit because time is always "normalized" to max one rotation
        (startHour: 0,   startMin: 0, finishHour: 27,  finishMin: 0,  rotation: ClockRotationCount.first.rawValue, expectedTime: 180),
        // second rotation
        (startHour: 0,   startMin: 0, finishHour: 3,  finishMin: 0,  rotation: ClockRotationCount.second.rawValue, expectedTime: 900),
        (startHour: 17, startMin: 15, finishHour: 23, finishMin: 59, rotation: ClockRotationCount.second.rawValue, expectedTime: 1124),
        (startHour: 22, startMin: 33, finishHour: 1,  finishMin: 33, rotation: ClockRotationCount.second.rawValue, expectedTime: 900),
        // selected time < one rotation
        (startHour: 23, startMin: 0,  finishHour: 23, finishMin: 25, rotation: ClockRotationCount.second.rawValue, expectedTime: 745),
    ]) func validateTimeRange(
        tuple: (startHour: Int, startMin: Int, finishHour: Int, finishMin: Int, rotation: Int, expectedTime: Int)
    ) {
        let model = TimeSliceViewModel(
            startTimeIsFixedToZero: false,
            clockType: ClockType.twelveHourClock,
            startTime: TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin),
            finishTime: TimeOfDayModel(hour: tuple.finishHour, minute: tuple.finishMin),
            clockRotationCount: ClockRotationCount(rawValue: tuple.rotation)!
        )
        let result = model.timeRange
        #expect(result == tuple.expectedTime)
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
    ]) func validateChangeTimeOfDayUsingClockFaceTime(
        tuple: (startHour: Int, startMin: Int, changedStartTime: Int, expectedHour: Int, expectedMin: Int)
    ) {
        let startTime = TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin)
        let viewModel = TimeSliceViewModel(
            startTimeIsFixedToZero: false,
            clockType: ClockType.twelveHourClock,
            startTime: startTime,
            finishTime: TimeOfDayModel(),
            clockRotationCount: ClockRotationCount.first,
            maximumTimeDuration: nil)
        let actualResult = viewModel.changeTimeOfDayUsingClockFaceTime(oldTimeOfDay: startTime,
                                                                       clockFaceTime: CGFloat(tuple.changedStartTime))
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(actualResult == expectedResult)
        
        let vm2 = TimeSliceViewModel(
            startTimeIsFixedToZero: false,
            clockType: ClockType.twentyFourHourClock,
            startTime: startTime,
            finishTime: TimeOfDayModel(),
            clockRotationCount: ClockRotationCount.second,
            maximumTimeDuration: nil)
        let result2 = vm2.changeTimeOfDayUsingClockFaceTime(oldTimeOfDay: startTime,
                                                            clockFaceTime: CGFloat(tuple.changedStartTime))
        let expectedResult2 = TimeOfDayModel.timeModelFromMinutes(tuple.changedStartTime)
        #expect(result2 == expectedResult2)
    }
    
    @Test(arguments: [
        (startHour: 0, startMin: 0, changedStartTime: 0   ),
        (startHour: 0, startMin: 0, changedStartTime: 60  ),
        (startHour: 0, startMin: 0, changedStartTime: 145 ),
    ]) func validateChangeStartTimeOfDayUsingClockFaceTime(
        tuple: (startHour: Int, startMin: Int, changedStartTime: Int)
    ) {
        let startTime = TimeOfDayModel(hour: tuple.startHour, minute: tuple.startMin)
        let viewModel = TimeSliceViewModel(
            startTimeIsFixedToZero: true,
            clockType: ClockType.twelveHourClock,
            startTime: startTime,
            finishTime: TimeOfDayModel(),
            clockRotationCount: ClockRotationCount.first,
            maximumTimeDuration: nil)
        viewModel.changeStartTimeOfDayUsingClockFaceTime(CGFloat(tuple.changedStartTime))
        let actualResult = viewModel.startTime
        let expectedResult = startTime
        #expect(actualResult == expectedResult)
    }
    
    @Test func validateRotationCount() {
        let viewModel = TimeSliceViewModel()
        #expect(viewModel.clockRotationCount == .first)
        
        viewModel.advanceRotationCountIfAllowed()
        #expect(viewModel.clockRotationCount == .second)
        
        viewModel.advanceRotationCountIfAllowed()
        #expect(viewModel.clockRotationCount == .second)
        
        viewModel.advanceRotationCountIfAllowed()
        #expect(viewModel.clockRotationCount == .second)
        
        viewModel.clockRotationCount.decrementCount()
        #expect(viewModel.clockRotationCount == .first)
        
        viewModel.clockRotationCount.decrementCount()
        #expect(viewModel.clockRotationCount == .first)
        
        viewModel.clockRotationCount.decrementCount()
        #expect(viewModel.clockRotationCount == .first)
        
        viewModel.maximumTimeDuration = 800
        viewModel.advanceRotationCountIfAllowed()
        #expect(viewModel.clockRotationCount == .second)
        
        viewModel.clockRotationCount.decrementCount()
        #expect(viewModel.clockRotationCount == .first)
        
        viewModel.maximumTimeDuration = 400
        viewModel.advanceRotationCountIfAllowed()
        viewModel.clockRotationCount.decrementCount()
        #expect(viewModel.clockRotationCount == .first)
    }
    
    @Test func validateSettingStartDayOrNight() {
        let viewModel = TimeSliceViewModel()
        
        // test string
        #expect(viewModel.startTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.startDayOrNightString == DayOrNight.am.rawValue)
        
        viewModel.startTime.setHours(14)
        #expect(viewModel.startTime.amORpm == .pm)
        #expect(viewModel.startDayOrNightString == DayOrNight.pm.rawValue)
        
        // test am/pm calculation logic
        viewModel.startTime.setHours(1)
        #expect(viewModel.startTime.amORpm ==  DayOrNight.am)
        
        viewModel.setStartDayOrNight(.pm)
        #expect(viewModel.startTime.amORpm ==  DayOrNight.pm)
        #expect(viewModel.startTime.hour == 13)
        
        viewModel.startTime.setHours(13)
        #expect(viewModel.startTime.amORpm ==  DayOrNight.pm)
        #expect(viewModel.startTime.hour == 13)
        
        // test using the setter
        viewModel.setStartDayOrNight(.am)
        #expect(viewModel.startTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.startTime.hour == 1)
        
        // user the setter with no change
        viewModel.setStartDayOrNight(.am)
        #expect(viewModel.startTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.startTime.hour == 1)
        
        // 24-hour clock should not respond to setStartDayOrNight
        viewModel.clockType = .twentyFourHourClock
        #expect(viewModel.startTime.amORpm == .am)
        viewModel.setStartDayOrNight(.pm)
        #expect(viewModel.startTime.amORpm == .am)
    }
    
    @Test func validateSettingFinishDayOrNight() {
        let viewModel = TimeSliceViewModel()
        
        // test string
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.finishDayOrNightString == DayOrNight.am.rawValue)
        
        viewModel.finishTime.setHours(14)
        #expect(viewModel.finishTime.amORpm == .pm)
        #expect(viewModel.finishDayOrNightString == DayOrNight.pm.rawValue)
        
        // test am/pm calculation logic
        viewModel.finishTime.setHours(1)
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.am)
        
        viewModel.setFinishDayOrNight(.pm)
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.pm)
        #expect(viewModel.finishTime.hour == 13)
        
        viewModel.finishTime.setHours(13)
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.pm)
        #expect(viewModel.finishTime.hour == 13)
        
        // test using the setter
        viewModel.setFinishDayOrNight(.am)
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.finishTime.hour == 1)
        
        // user the setter with no change
        viewModel.setFinishDayOrNight(.am)
        #expect(viewModel.finishTime.amORpm ==  DayOrNight.am)
        #expect(viewModel.finishTime.hour == 1)
        
        // 24-hour clock should not respond to setStartDayOrNight
        viewModel.clockType = .twentyFourHourClock
        #expect(viewModel.finishTime.amORpm == .am)
        viewModel.setFinishDayOrNight(.pm)
        #expect(viewModel.finishTime.amORpm == .am)
    }
    
    @Test(arguments: [
        (oldTimeRange: 0, newTimeRange: 0, initialRotationCount:ClockRotationCount.first.rawValue , expectedRotationCount: ClockRotationCount.first.rawValue),
        (oldTimeRange: 715, newTimeRange: 5, initialRotationCount:ClockRotationCount.first.rawValue , expectedRotationCount: ClockRotationCount.second.rawValue),
        (oldTimeRange: 23, newTimeRange: 707, initialRotationCount:ClockRotationCount.second.rawValue , expectedRotationCount: ClockRotationCount.first.rawValue)
    ]) func validateChangingRotationCountIfNeeded(
        tuple: (oldTimeRange: Int, newTimeRange: Int, initialRotationCount: Int, expectedRotationCount: Int)
    ) {
        let initialCount = ClockRotationCount(rawValue: tuple.initialRotationCount)!
        let viewModel = TimeSliceViewModel(
            clockType: .twelveHourClock,
            clockRotationCount: initialCount
        )
        #expect(viewModel.clockRotationCount == initialCount)
        viewModel.changeRotationCountIfNeeded(tuple.oldTimeRange, newTimeRange: tuple.newTimeRange)
        #expect(viewModel.clockRotationCount.rawValue == tuple.expectedRotationCount)
        
        let vm2 = TimeSliceViewModel(
            clockType: .twentyFourHourClock,
            clockRotationCount: initialCount
        )
        #expect(vm2.clockRotationCount == initialCount)
        let oldTR = tuple.oldTimeRange * 2
        let newTR = tuple.newTimeRange * 2
        vm2.changeRotationCountIfNeeded(oldTR, newTimeRange: newTR)
        #expect(viewModel.clockRotationCount.rawValue == tuple.expectedRotationCount)
    }
    
    @Test(arguments: [
        // 12-hour clock
        (unsafeMinutes: 0, clockType: ClockType.twelveHourClock.rawValue, expectedMinutes: 0),
        (unsafeMinutes: 719, clockType: ClockType.twelveHourClock.rawValue, expectedMinutes: 719),
        (unsafeMinutes: 2882, clockType: ClockType.twelveHourClock.rawValue, expectedMinutes: 2),
        (unsafeMinutes: -2, clockType: ClockType.twelveHourClock.rawValue, expectedMinutes: 718),
        (unsafeMinutes: 1200, clockType: ClockType.twelveHourClock.rawValue, expectedMinutes: 480),
        // 24-hour clock
        (unsafeMinutes: 0, clockType: ClockType.twentyFourHourClock.rawValue, expectedMinutes: 0),
        (unsafeMinutes: 719, clockType: ClockType.twentyFourHourClock.rawValue, expectedMinutes: 719),
        (unsafeMinutes: 2882, clockType: ClockType.twentyFourHourClock.rawValue, expectedMinutes: 2),
        (unsafeMinutes: -2, clockType: ClockType.twentyFourHourClock.rawValue, expectedMinutes: 1438),
        (unsafeMinutes: 1200, clockType: ClockType.twentyFourHourClock.rawValue, expectedMinutes:1200),
    ]) func validateConverstionOfMinutesToSafeMinutes(
        tuple: (unsafeMinutes: Int, clockType: Int, expectedMinutes: Int)
    ) {
        let clockType = ClockType(rawValue: tuple.clockType)!
        let result = TimeSliceViewModel.convertMinutesToSafeMinutes(tuple.unsafeMinutes, clockType: clockType)
        #expect(result == tuple.expectedMinutes)
    }
}
