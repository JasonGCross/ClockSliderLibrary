//
//  TimeRangeSliderController.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import QuartzCore

public class TimeRangeSliderControlViewModel: NSObject {
    
    // MARK:- other view models
    public var clockFaceViewModel: ClockFaceViewModel
    internal var clockSliderViewModel: ClockSliderViewModel
    internal var timeSliceViewModel: TimeSliceViewModel
    internal var startKnobViewModel: ThumbnailViewModel
    internal var finishKnobViewModel: ThumbnailViewModel
      
    // MARK:- pure data fields
    public var clockType: ClockType { timeSliceViewModel.clockType }
    internal var previousTouchPoint: CGPoint = CGPoint.zero
    internal var clockRadius: CGFloat
    internal var radiusClockCenterToSliderTrackCenter: CGFloat
    /// minimum distance allowed to the center of the circle before drag events are ignored
    internal var dragTolerance: CGFloat = 30
    internal var startLockedToMidnight: Bool = false
    public var lastDraggedThumbKnob: HighlightedKnob  {
        get {
            if self.startKnobViewModel.isHighlighted {
                return HighlightedKnob.start
            }
            else if self.finishKnobViewModel.isHighlighted {
                return HighlightedKnob.finish
            }
                return HighlightedKnob.neitherThumbKnob
        }
        set {
            switch newValue {
                case HighlightedKnob.start:
                    self.startKnobViewModel.isHighlighted = true
                    self.finishKnobViewModel.isHighlighted = false
                case HighlightedKnob.finish:
                    self.startKnobViewModel.isHighlighted = false
                    self.finishKnobViewModel.isHighlighted = true
                case .neitherThumbKnob:
                    self.startKnobViewModel.isHighlighted = false
                    self.finishKnobViewModel.isHighlighted = false
            }
        }
    }
    public var thumbWithHigherZIndex: HighlightedKnob = .neitherThumbKnob
    internal let angleEquivalentToOnePixel: CGFloat = CGFloat(Double.pi / 360.0)
    var incrementDurationInMinutes: Int = 30
    
    //MARK: - constructor
//    init(clockFaceViewModel: ClockFaceViewModel,
//         clockSliderViewModel: ClockSliderViewModel,
//         timeSliceViewModel: TimeSliceViewModel,
//         startKnobView: ThumbnailViewModel,
//         finishKnobView: ThumbnailViewModel,
//         previousTouchPoint: CGPoint,
//         clockRadius: CGFloat,
//         radiusClockCenterToSliderTrackCenter: CGFloat,
//         dragTolerance: CGFloat,
//         startLockedToMidnight: Bool,
//         lastDraggedThumbKnob: HighlightedKnob,
//         thumbWithHigherZIndex: HighlightedKnob,
//         incrementDurationInMinutes: Int) {
//        self.clockFaceViewModel = clockFaceViewModel
//        self.clockSliderViewModel = clockSliderViewModel
//        self.timeSliceViewModel = timeSliceViewModel
//        self.startKnobViewModel = startKnobView
//        self.finishKnobViewModel = finishKnobView
//        self.previousTouchPoint = previousTouchPoint
//        self.clockRadius = clockRadius
//        self.radiusClockCenterToSliderTrackCenter = radiusClockCenterToSliderTrackCenter
//        self.dragTolerance = dragTolerance
//        self.startLockedToMidnight = startLockedToMidnight
//        self.lastDraggedThumbKnob = lastDraggedThumbKnob
//        self.thumbWithHigherZIndex = thumbWithHigherZIndex
//        self.incrementDurationInMinutes = incrementDurationInMinutes
//    }
    
    internal init(frame: CGRect,
                ringWidth: CGFloat,
                clockType: ClockType,
                timeOfDay: TimeOfDayModel,
                sliderStartTime: TimeOfDayModel,
                sliderEndTime: TimeOfDayModel,
                screenScale: CGFloat
    ) {
        // create 5 other required view models
        // 1.
        self.clockFaceViewModel = ClockFaceViewModel(clockType: clockType,
                                                     clockTime: timeOfDay)
        
        // 2.
        self.clockSliderViewModel = ClockSliderViewModel(
            _frame: frame,
            _clockType: clockType,
            _ringWidth: ringWidth,
            _sliderStartMinutes: sliderStartTime.totalMinutes,
            _sliderEndMinutes: sliderEndTime.totalMinutes,
            _clockRotationCount: ClockRotationCount.first,
            _screenScale: screenScale
        )
        
        // 3.
        // this keeps track of the position of the thumbs (based on times / angles)
        self.timeSliceViewModel = TimeSliceViewModel(
            clockType: clockType,
            startTime: sliderStartTime,
            finishTime: sliderEndTime
        )
        
        let sliderStartAngle = clockSliderViewModel.sliderStartAngle
        let sliderEndAngle = clockSliderViewModel.sliderEndAngle
        // 4.
        // simply tracks touches and highlighted state
        self.startKnobViewModel = ThumbnailViewModel(drawableEndAngle: sliderStartAngle)
        
        // 5.
        // simply tracks touches and highlighted state
        self.finishKnobViewModel = ThumbnailViewModel(drawableEndAngle: sliderEndAngle)
        
        let diameter = CGFloat(fminf(Float(frame.size.width),
                                     Float(frame.size.height)))
        self.clockRadius = diameter / 2.0
        let ringWidth = clockSliderViewModel.ringWidth
        let halfSliderTrackWidth = (ringWidth / 2.0)
        
        // uses the fact that lines are stroked half on each side of the line
        self.radiusClockCenterToSliderTrackCenter = clockRadius - halfSliderTrackWidth
        
        super.init()
    }
    
    //MARK:- convenience getters
    public func getDrawableStartAngle() -> CGFloat {
        return self.clockSliderViewModel.sliderStartAngle
    }
    
    public func getDrawableEndAngle() -> CGFloat {
        return self.clockSliderViewModel.sliderEndAngle
    }
    
    func getStartTime() -> TimeOfDayModel {
        return self.timeSliceViewModel.startTime
    }
    
    func getFinishTime() -> TimeOfDayModel {
        return self.timeSliceViewModel.finishTime
    }
    
    //MARK:- touch handling
    public func beginTracking(at location: CGPoint) {
        self.previousTouchPoint = location
        
        // hit test the thumbnail layers
        // we need to implement a Z-index here, so that the last dragged thumbnail gets dragged first
        // Three scenarios:
        //   1. the start knob is locked - never highlight it
        //   2. the finish knob is highlighted - consider it first
        //   3. the finish knob is NOT highlighted - consider it last
        
        // case 1
        if (self.startLockedToMidnight) {
            if (self.finishKnobViewModel.touchPointIsInsideThisView(self.previousTouchPoint)) {
                self.lastDraggedThumbKnob = HighlightedKnob.finish
            }
        }
        else if (self.lastDraggedThumbKnob == HighlightedKnob.finish) {
            if (self.finishKnobViewModel.touchPointIsInsideThisView(self.previousTouchPoint)) {
                self.lastDraggedThumbKnob = HighlightedKnob.finish
            }
            else if(self.startKnobViewModel.touchPointIsInsideThisView(self.previousTouchPoint)) {
                self.lastDraggedThumbKnob = HighlightedKnob.start
            }
        }
        else {
            if(self.startKnobViewModel.touchPointIsInsideThisView(self.previousTouchPoint)) {
                self.lastDraggedThumbKnob = HighlightedKnob.start
            }
            else if (self.finishKnobViewModel.touchPointIsInsideThisView(self.previousTouchPoint)) {
                self.lastDraggedThumbKnob = HighlightedKnob.finish
            }
        }
    }
    
    public func continueTracking(location: CGPoint) {
        let touchPoint: CGPoint = location
        
        // 1. determine by how much the user has dragged
        // 2. update the value of the max or min minutes
        self.adjustStartAndEndTimesDuringTracking(location: touchPoint, highlightedKnob: self.lastDraggedThumbKnob)
        
        // This view model does not have to keep track of the angle of the thumbnail
        // or the start or finish time. Other view models store this information.
        // The NSView / UIView which calls this method is responsible for asking the view hierarchy
        // to redraw / update.
        
        // old code: ClockSliderview.setClock was called (resulted in a redraw)
        
        
        // 3. update which knob was last dragged
        if(self.startKnobViewModel.isHighlighted && !self.startLockedToMidnight) {
            self.lastDraggedThumbKnob = .start
        }
        else if (self.finishKnobViewModel.isHighlighted) {
            self.lastDraggedThumbKnob = .finish
        }
    }
    
    public func endTracking(location: CGPoint) {
        // during tracking, we want a smooth animation, so allow selecting any number of minutes
        // after the user is finished, clean up by moving to the nearest allowable minute

        var newTimeSpan = TimeSliceViewModel.timeSpanBetween(self.getStartTime(),
                                                             finishTime: self.getFinishTime())
        if (self.timeSliceViewModel.clockRotationCount == .second) {
            newTimeSpan += self.timeSliceViewModel.numberOfMinutesPerClockRotation
        }
        
        if(self.startKnobViewModel.isHighlighted) {
            if (newTimeSpan > self.timeSliceViewModel.maxAllowedMinutes) {
                let currentEndThumb = self.clockSliderViewModel.thumbnailCenterPoint(self.getFinishTime().totalMinutes)
                let maximumMinutes = self.maximumAllowedStartMinutesStartingFromFinishThumbCenter(currentEndThumb)
                self.timeSliceViewModel.startTime = TimeOfDayModel.timeModelFromMinutes(maximumMinutes)
            }
            let roundedMinutes = ClockSliderViewModel.roundMinutesToMatchIncrementDuration(self.getStartTime().totalMinutes,
                                                                                           incrementDuration: self.incrementDurationInMinutes)
            self.timeSliceViewModel.startTime = TimeOfDayModel.timeModelFromMinutes(roundedMinutes)
        }
        else if (self.finishKnobViewModel.isHighlighted) {
            if (newTimeSpan > self.timeSliceViewModel.maxAllowedMinutes) {
                let currentStartThumb = self.clockSliderViewModel.thumbnailCenterPoint(self.getStartTime().totalMinutes)
                let maximumMinutes = self.maximumAllowedFinishMinutesStartingFromStartThumbCenter(currentStartThumb)
                self.timeSliceViewModel.finishTime = TimeOfDayModel.timeModelFromMinutes(maximumMinutes)
            }
            let roundedMinutes = ClockSliderViewModel.roundMinutesToMatchIncrementDuration(self.getFinishTime().totalMinutes,
                                                                                           incrementDuration: self.incrementDurationInMinutes)
            self.timeSliceViewModel.finishTime = TimeOfDayModel.timeModelFromMinutes(roundedMinutes)
        }
        
        self.lastDraggedThumbKnob = HighlightedKnob.neitherThumbKnob
    }
    
    //MARK: - private helpers
    //*************************************************************************
    fileprivate func maximumTimeSpanMinutes() -> Int {
        let maxAllowedMinutes: CGFloat = CGFloat(self.timeSliceViewModel.maxAllowedMinutes)
        let numberOfRotations = Double(self.timeSliceViewModel.numberOfMinutesPerClockRotation)
        return Int(maxAllowedMinutes.truncatingRemainder(dividingBy: numberOfRotations))
    }
    
    fileprivate func maximumAllowedStartMinutesStartingFromFinishThumbCenter(_ screenPoint: CGPoint) -> Int {
        let minutesToTravelBackwards: Int = self.maximumTimeSpanMinutes()
        let innerAngle: CGFloat = self.clockSliderViewModel.clockFaceAngle(screenMinutes: minutesToTravelBackwards)
        let minutesAsFloat = self.findMinutesOnClockCircle(screenPoint,
                                              innerAngle: innerAngle,
                                              clockwise: false)
        return Int(minutesAsFloat.rounded())
    }
    
    fileprivate func maximumAllowedFinishMinutesStartingFromStartThumbCenter(_ screenPoint: CGPoint) -> Int {
        let desiredFinishMinutes: Int = self.maximumTimeSpanMinutes()
        let innerAngle: CGFloat = self.clockSliderViewModel.clockFaceAngle(screenMinutes: desiredFinishMinutes)
        let minutesAsFloat = self.findMinutesOnClockCircle(screenPoint,
                                              innerAngle: innerAngle,
                                              clockwise: true)
        return Int(minutesAsFloat.rounded())
    }
    
    internal func findMinutesOnClockCircle(_ screenPointA: CGPoint, innerAngle: CGFloat, clockwise: Bool) -> CGFloat {
        // see this site: http://math.stackexchange.com/questions/275201/how-to-find-an-end-point-of-an-arc-given-another-end-point-radius-and-arc-dire
        let mappedPointA = self.mapScreenPointToSliderCenterTrackPoint(screenPointA)
        let angleToStartPoint = CGFloat(atan2(mappedPointA.y, mappedPointA.x))
        var angleToEndPoint = clockwise ? (angleToStartPoint - innerAngle) : (angleToStartPoint + innerAngle)
        if (angleToEndPoint < 0) {
            angleToEndPoint += CGFloat(2 * Double.pi)
        }
        
        let Bx = self.radiusClockCenterToSliderTrackCenter * cos(angleToEndPoint)
        let By = self.radiusClockCenterToSliderTrackCenter * sin(angleToEndPoint)
        let pointB = CGPoint(x:Bx, y:By)
        let value = self.minutesForThumnailCenter(pointB).minutes
        return value
    }
    
    /**
     takes a point from the normal screen system (origin is top left, with x increasing to the right,
     and y increasing downwards), and maps it to a point which may be used to perform geometric
     calculations based on a circle with its center in the center of the view, and the y axis
     increasing upwards instead of downwards, with a radius of the center of the slider track
     
     - parameter screenPoint: the point using the coordinates of this view object
     
     - returns: cartesianPoint the point using the cartesian coordinate system with the circle's radius at its center
     */
    fileprivate func mapScreenPointToSliderCenterTrackPoint(_ screenPoint: CGPoint) -> CGPoint {
        return CGPoint(x: screenPoint.x - self.clockRadius,
                       y: self.clockRadius - screenPoint.y)
    }
    
    fileprivate func closestPointOnSliderCenterTrack(_ dragPoint: CGPoint) -> CGPoint? {
        
        // Consider these options for where the drag point lies in relation to the circle
        //   1. The drag point is in the exact center of the circle
        //   2. The drag point is outside the circle
        //   3. The drag point is inside the circle
        //
        // the second two cases may be dealt with similarily
        // First find the equation describing the line formed by joining the circle origin, and the drag point
        // Next, find the two intercepts of the circle with this line (there must be exactly two, since the circle intersects the origin, it must pass through two sides of the circle no matter what angle)
        // Lastly, pick the closest of the two intercepts
        
        // in order to have intercepts with the axis, must translate the circle
        // may as well translate it so that the center of the circle is the origin
        
        let mappedDragPoint = CGPoint(x:dragPoint.x - self.clockRadius, y:dragPoint.y - self.clockRadius)
        let centerOfCircle = CGPoint.zero
        
        let distanceToCenter = mappedDragPoint.distanceToPoint(centerOfCircle)
        if (distanceToCenter < dragTolerance) {
            return nil
        }
        
        let circleCenter = centerOfCircle
        let h = centerOfCircle.x
        let k = centerOfCircle.y
        let r = self.radiusClockCenterToSliderTrackCenter
        
        let intercept = mappedDragPoint.closestInterceptPointToCircle(circleCenter,
                                                                      circleXIntercept: h,
                                                                      circleYIntercept: k,
                                                                      circleRadius: r)
        
        // remember to un-map the found point
        let value = CGPoint(x:intercept.x + self.clockRadius, y:intercept.y + self.clockRadius)
        return value
    }
    
    fileprivate func minutesForThumnailCenter(_ cartesianCoordinatePoint: CGPoint) -> (minutes:CGFloat, angle:CGFloat) {
        let angle = self.translateSliderCenterPointToAngle(cartesianCoordinatePoint)
        if (angle.isNaN) {
            // try this calculation again
            let garbage = self.translateSliderCenterPointToAngle(cartesianCoordinatePoint)
            print("\(garbage)")
            return (0, 0)
        }
        let minutes = self.minutesForClockFaceAngle(angle)
        return (minutes, angle)
    }
    
    fileprivate func clockFaceAngle(_ cartesianCoordinateCirclePoint: CGPoint) -> CGFloat {
        
        // with the center of the clock face as the origin, we can use the diagram below
        //
        //                      x
        //                    |---------
        //                    |        /
        //                    |       /
        //                  y |      /
        //                    |     /  radius
        //                    |    /
        //                    | O /
        //                    |  /
        //                    | /
        //                    |/
        //
        // using this formula: sin(theta) = oposite / hypoteneuse
        // sin(angle) = x / radius
        // angle = asin(x / radius)
        
        // the above geometry only works when we are between 0 and 3 o'clock
        let quadrant: ClockQuadrant = ClockQuadrant.mapPointToQuadrant(cartesianCoordinateCirclePoint)
        
        switch (quadrant) {
        case .first:
            var angle = asin(cartesianCoordinateCirclePoint.x / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            if (angle.isNaN) {
                angle = asin( round(cartesianCoordinateCirclePoint.x) / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            }
            return angle
            
        case .second:
            var angle = asin(cartesianCoordinateCirclePoint.x / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            if angle.isNaN {
                angle = asin(round(cartesianCoordinateCirclePoint.x) / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            }
            angle = CGFloat(Double.pi) - angle
            return angle
            
        case .third:
            var angle = asin(-cartesianCoordinateCirclePoint.x / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            if (angle.isNaN) {
                angle = asin( round(-cartesianCoordinateCirclePoint.x) / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            }
            angle = CGFloat(Double.pi) + angle
            return angle
            
        case .fourth:
            var angle = asin(-cartesianCoordinateCirclePoint.x / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            if (angle.isNaN) {
                angle = asin( round(-cartesianCoordinateCirclePoint.x) / CGFloat(self.radiusClockCenterToSliderTrackCenter))
            }
            angle = CGFloat(2.0 * Double.pi) - angle
            return angle
        }
    }
    
    internal func translateTouchLocationToSliderCenterPoint(_ touchLocation: CGPoint) -> CGPoint? {
        
        // determine by how much the user has dragged
        guard let bestInterceptPoint = self.closestPointOnSliderCenterTrack(touchLocation) else {
            return nil
        }
        let mappedIntercept = self.mapScreenPointToSliderCenterTrackPoint(bestInterceptPoint)
        return mappedIntercept
    }
    
    internal func translateSliderCenterPointToAngle(_ cartesianCoordinatePoint: CGPoint) -> CGFloat {
        let angle = self.clockFaceAngle(cartesianCoordinatePoint)
        if (angle.isNaN) {
            // try this calculation again
            let garbage = self.clockFaceAngle(cartesianCoordinatePoint)
            print("\(garbage)")
            return 0
        }
        return angle
    }
    
    internal func minutesForClockFaceAngle(_ angle: CGFloat) -> CGFloat {
        // angle = (minutes / ticksPerRevolution) * 2 * Pi
        // angle / (2 * Pi) = (minutes / ticksPerRevolution)
        // minutes = (angle * ticksPerRevolution) / (2 * Pi)
        let rawMinutes = (angle * CGFloat(self.clockType.minutesPerRevolution())) / CGFloat(2 * Double.pi)
        //let numberOfTicks: Int = Int(rawMinutes.rounded())
        
        return rawMinutes
    }
    
    public func originForThumbnail(_ minutes: Int) -> CGPoint {
        var value = CGPoint.zero
        let centerPoint = self.clockSliderViewModel.thumbnailCenterPoint(minutes)
        let originPoint = CGPoint(x:centerPoint.x - self.clockSliderViewModel.halfSliderTrackWidth,
                                  y:centerPoint.y - self.clockSliderViewModel.halfSliderTrackWidth)
        value = originPoint
        return value
    }
    
    internal func adjustStartAndEndTimesDuringTracking(location: CGPoint, highlightedKnob: HighlightedKnob) {
        //1. Screen Point:  e.g. (x=200, y=75)
        //The user's drag is reported in absolute screen coordinates.
        let screenPoint: CGPoint = location
        self.previousTouchPoint = screenPoint
        
        //2. Slider Centre Point: e.g. (x=60, y=60)
        //The screen point is converted to a point along the centre of the slider track,
        //using the centre of the clock face as (0,0) instead of the view's upper left corner.
        guard let sliderCenterPoint = translateTouchLocationToSliderCenterPoint(screenPoint) else {
            return print("Could not translate touch location to slider center point")
        }
        
        //3. Angle: e.g. 0.785 radians
        //The point in the centre of the slider track is converted to an angle,
        //the angle between the vertical line (12 o'clock) and the intercept to the slider centre point.
        let angle = self.translateSliderCenterPointToAngle(sliderCenterPoint)
        
        //4. Raw Minutes on Clock Face: e.g. 90 minutes
        //The angle is converted to raw minutes which the hour hand should lie on the clock face.
        //This position of the hour hand is different between 12-hour clocks and 24-hour clocks.
        //For 12-hour clocks, this time can only be a number between 0 minutes and 720 minutes (12 * 60).
        //Both AM and PM will show the same clock face time.
        let rawMinutes = self.minutesForClockFaceAngle(angle)
        
        //5. Time of Day Time: e.g. 1:30pm, or 13:30 = 810 minutes
        //For a 24-hour clock, the time of day is always the same as the clock face time.
        //But for a 12-hour clock, the time of day is only the same as the clock face time before noon.
        //After noon, the actual time of day is 12 hours greater.
        //For example, 1:30 on the clock is 13:30 of actual time.
        //In order to perform this calculation, more than just the Clock Face Time and clock type are
        //needed. The old time of day is also needed as it must be determined if a change from am to pm
        //is required or not.
        switch highlightedKnob {
        case .start:
            self.clockSliderViewModel.sliderStartAngle = angle
            self.timeSliceViewModel.changeStartTimeOfDayUsingClockFaceTime(rawMinutes)
            self.startKnobViewModel.drawableEndAngle = angle
        case .finish:
            self.clockSliderViewModel.sliderEndAngle = angle
            self.timeSliceViewModel.changeFinishTimeOfDayUsingClockFaceTime(rawMinutes)
            self.finishKnobViewModel.drawableEndAngle = angle
        case .neitherThumbKnob:
            break
        }
    }
}

extension TimeRangeSliderControlViewModel {
    
    //MARK: - testing
    //*************************************************************************
    
    func test_mapScreenPointToSliderCenterTrackPoint(_ screenPoint: CGPoint) -> CGPoint {
        return mapScreenPointToSliderCenterTrackPoint(screenPoint)
    }
    
    func test_translateTouchLocationToSliderCenterPoint(_ touchLocation: CGPoint) -> CGPoint? {
        return translateTouchLocationToSliderCenterPoint(touchLocation)
    }
    
    func test_clockFaceAngle(_ point: CGPoint) -> CGFloat {
        return self.clockFaceAngle(point)
    }
    
    func test_translateSliderCenterPointToAngle(_ point: CGPoint) -> CGFloat {
        return self.translateSliderCenterPointToAngle(point)
    }

    func test_minutesForClockFaceAngle(_ angle: CGFloat) -> CGFloat {
        return self.minutesForClockFaceAngle(angle)
    }
}
