//
//  SliderControlViewModelTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-24.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct SliderControlViewModelTests {
 
    @Test(arguments: [
        (p1x: 0.0, p1y: 0.0, p2x: -100.0, p2y: 100.0),
        (p1x: 100.0, p1y: 100.0, p2x: 0.0, p2y: 0.0),
        (p1x: 150.0, p1y: 10.0, p2x: 50.0, p2y: 90.0),
        (p1x: 30, p1y: 30.0, p2x: -70.0, p2y: 70.0),
        (p1x: 145.0, p1y: 170.0, p2x: 45.0, p2y: -70.0),
    ]) func validateMappingScreenPointToSliderCenterPoint(
        tuple: (p1x: Double, p1y: Double, p2x: Double, p2y: Double)
    ) {
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel()
        let screenPoint: CGPoint = CGPoint(x: tuple.p1x, y: tuple.p1y)
        let viewModel = SliderControlViewModel(
            clockRadius: 100,
            radiusClockCenterToSliderTrackCenter: 100 + (44 / 2),
            sliderViewModel: timeSliceViewModel)
        let sliderCenterPoint: CGPoint = viewModel.test_mapScreenPointToSliderCenterTrackPoint(screenPoint)
        #expect(abs(sliderCenterPoint.x - tuple.p2x) <= 0.0001)
        #expect(abs(sliderCenterPoint.y - tuple.p2y) <= 0.0001)
    }
    
    @Test(arguments:[
        // these values were captured from debugging a live running app and dragging
        (p1x: 335.98046875, p1y: 320.48046875, p2x:  58.381220192176784, p2y: -51.72652248965295 ),
        (p1x: 257.3828125, p1y: 29.45703125, p2x:24.874450396609404, p2y: 73.92740843196532),
        (p1x: 361.97265625, p1y: 269.86328125, p2x: 71.62164473545795, p2y: -30.892393973077674),
        (p1x: 37.31640625, p1y: 126.84765625, p2x: -71.13891953955414, p2y: 31.988343607396217),
        (p1x: 43.27734375, p1y: 281.15625, p2x: -69.26423111088886, p2y: -35.86734292664258),
        (p1x: 200.0, p1y: 0.0, p2x: 0.0, p2y: 78.0),
    ]) func validateTranslatingTouchLocationToSliderCenterPoint(
        tuple: (p1x: Double, p1y: Double, p2x: Double, p2y: Double)
    )  throws {
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let touchLocation = CGPoint(x: tuple.p1x, y: tuple.p1y)
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel()
        let viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)
        let mappedInterceptPoint: CGPoint? = viewModel.test_translateTouchLocationToSliderCenterPoint(touchLocation)
        try #require(nil != mappedInterceptPoint)
        let safeResult: CGPoint = mappedInterceptPoint!
        #expect(abs(safeResult.x - tuple.p2x) <= 0.0001)
        #expect(abs(safeResult.y - tuple.p2y) <= 0.0001)
    }
    
    @Test func validateClosestPointInvalidData() {
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let touchLocation = CGPoint(x: 201.0, y: 201.0)
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel()
        let viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)
        let mappedInterceptPoint: CGPoint? = viewModel.test_translateTouchLocationToSliderCenterPoint(touchLocation)
        #expect(nil == mappedInterceptPoint)
    }
    
    @Test(arguments:[
        (x: 0.0, y: 0.0, expectedAngle: 0.0),
        (x: -77.08453325465366, y: 11.915315057193993, expectedAngle: 4.865749886979605),
        (x: 22.915863468334976, y: 74.55778431190556, expectedAngle: 0.29819267495268725),
        (x: 73.71509267605859, y: -25.49676669227091, expectedAngle: 1.903798370339918),
        (x: -37.19396187081969, y: -68.56098891025431, expectedAngle: 3.6386552559029925),
    ]) func validateMappingSliderCentrePointToClockFaceAngle(
        tuple: (x: CGFloat, y: CGFloat, expectedAngle: CGFloat)
    ) {
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(clockType: .twelveHourClock)
        let viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)
        let mappedInterceptPoint: CGPoint = CGPoint(x: tuple.x, y: tuple.y)
        let angle = viewModel.test_clockFaceAngle(mappedInterceptPoint)
        #expect(abs(angle - tuple.expectedAngle) <= 0.0001)
        
        // there should be no difference between a 12-hour and 24-hour clock
        let tsModel2 = TimeSliceViewModel(clockType: .twelveHourClock)
        let vm2 = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: tsModel2)
        let angle2 = vm2.test_clockFaceAngle(mappedInterceptPoint)
        #expect(abs(angle2 - tuple.expectedAngle) <= 0.0001)
    }
    
    @Test(arguments:[
        (x: 150.0,  y: 75.0  ),
        (x: 150.0,  y: -75.0  ),
        (x: 150.0,  y: 150.0 ),
        (x: -150.0, y: 75.0  ),
        (x: -150.0, y: -75.0 ),
    ]) func validateClockFaceAngleInvalidData(
        tuple: (x: CGFloat, y: CGFloat)
    ) {
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(clockType: .twelveHourClock)
        let viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)
        let mappedInterceptPoint: CGPoint = CGPoint(x: tuple.x, y: tuple.y)
        let angle = viewModel.test_clockFaceAngle(mappedInterceptPoint)
        #expect(angle.isNaN)
        
        let result2 = viewModel.test_translateSliderCenterPointToAngle(mappedInterceptPoint)
        #expect(result2 == 0)
    }
    
    @Test(arguments:[
        (angle: 0.524923243696617, expectedMinutes: 120.3035457285336),
        (angle: 1.4731115178622707, expectedMinutes: 337.6122909024748),
        (angle: 1.7293870161949412, expectedMinutes: 396.34630869077074),
        (angle: 2.2906229949520114, expectedMinutes: 524.9721202654669),
        (angle: 3.2988812804531853, expectedMinutes: 756.0478979387216),
        (angle: 4.3284355505145005, expectedMinutes: 992.0043557554636),
        (angle: 4.715844651895914, expectedMinutes: 1080.791981571907),
        (angle: 6.09394545131161, expectedMinutes: 1396.6294197724037),
    ]) func validateMappingAngleToMinutes(
        tuple: (angle: Double, expectedMinutes: Double)
    ) {
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(clockType: .twentyFourHourClock)
        let viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)
        let minutes = viewModel.test_minutesForClockFaceAngle(tuple.angle)
        #expect(abs(CGFloat(minutes) - tuple.expectedMinutes) <= 1)
        
        // a 12-hour clock versus a 24-hour clock should have half the minutes
        let tsModel2 = TimeSliceViewModel(clockType: .twelveHourClock)
        let vm2 = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: tsModel2)
        let minutes2 = vm2.test_minutesForClockFaceAngle(tuple.angle)
        let expectedMInutes2: CGFloat = tuple.expectedMinutes / 2.0
        #expect(abs(CGFloat(minutes2) - expectedMInutes2) <= 1)
    }
    
    @Test(arguments:[
        (hour: 0, min: 0, px: 150.0, py: 75.0, resultHour: 2, resultMin: 6),
        (hour: 5, min: 59, px: 145.0, py: 200.0, resultHour: 5, resultMin: 11)
    ]) func validateFullRoundOfTouchToTimeStart(
        tuple: (hour: Int, min: Int, px: CGFloat, py: CGFloat, resultHour: Int, resultMin: Int)
    ) {
        let startTime = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(
            clockType: ClockType.twelveHourClock,
            startTime: startTime
        )
        let screenPoint: CGPoint = CGPoint(x: tuple.px, y: tuple.py)
        var viewModel = SliderControlViewModel(
            clockRadius: 100,
            radiusClockCenterToSliderTrackCenter: 100 + (44 / 2),
            sliderViewModel: timeSliceViewModel)
        viewModel.adjustStartAndEndTimesDuringTracking(location: screenPoint, highlightedKnob: .start)
        let resultTime = viewModel.sliderViewModel.startTime
        let expectedTime = TimeOfDayModel(hour: tuple.resultHour, minute: tuple.resultMin)
        #expect(resultTime == expectedTime)
    }
    
    @Test(arguments:[
        (hour: 0, min: 0, px: 150.0, py: 75.0, resultHour: 2, resultMin: 6),
        (hour: 5, min: 59, px: 145.0, py: 200.0, resultHour: 5, resultMin: 11)
    ]) func validateFullRoundOfTouchToTimeFinish(
        tuple: (hour: Int, min: Int, px: CGFloat, py: CGFloat, resultHour: Int, resultMin: Int)
    ) {
        let finishTime = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(
            clockType: ClockType.twelveHourClock,
            finishTime: finishTime
        )
        let screenPoint: CGPoint = CGPoint(x: tuple.px, y: tuple.py)
        var viewModel = SliderControlViewModel(
            clockRadius: 100,
            radiusClockCenterToSliderTrackCenter: 100 + (44 / 2),
            sliderViewModel: timeSliceViewModel)
        viewModel.adjustStartAndEndTimesDuringTracking(location: screenPoint, highlightedKnob: .finish)
        let resultTime = viewModel.sliderViewModel.finishTime
        let expectedTime = TimeOfDayModel(hour: tuple.resultHour, minute: tuple.resultMin)
        #expect(resultTime == expectedTime)
    }
    
    @Test func validateNoChangeWhenSliderToInvalidPosition() {
        let startTime = TimeOfDayModel(hour: 0, minute: 0)
        let timeSliceViewModel: TimeSliceViewModel = TimeSliceViewModel(
            clockType: ClockType.twelveHourClock,
            finishTime: startTime
        )
        let radius: CGFloat = 200
        let radiusClockCenterToSliderTrackCenter: CGFloat = 78
        let touchLocation = CGPoint(x: 201.0, y: 201.0)
        var viewModel = SliderControlViewModel(
            clockRadius: radius,
            radiusClockCenterToSliderTrackCenter: radiusClockCenterToSliderTrackCenter,
            sliderViewModel: timeSliceViewModel)

        viewModel.adjustStartAndEndTimesDuringTracking(location: touchLocation, highlightedKnob: .start)
        let resultTime = viewModel.sliderViewModel.startTime
        #expect(resultTime == startTime)
    }
}
