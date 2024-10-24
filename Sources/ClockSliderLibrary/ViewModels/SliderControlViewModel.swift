//
//  SliderControlViewModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import QuartzCore

public struct SliderControlViewModel {
      
    var clockType: ClockType { sliderViewModel.clockType }
    internal var previousTouchPoint: CGPoint = CGPoint.zero
    internal var clockRadius: CGFloat
    internal var radiusClockCenterToSliderTrackCenter: CGFloat
    /// one revolution of the clock contains 12 hours * 60 minutes
    internal var ticksPerRevolution: Int { self.clockType.rawValue * 60 }
    /// minimum distance allowed to the center of the circle before drag events are ignored
    internal var dragTolerance: CGFloat = 30
    
    internal var sliderViewModel: TimeSliceViewModel
    
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
    
    public mutating func translateTouchLocationToSliderCenterPoint(_ touchLocation: CGPoint) -> CGPoint? {
        
        // 1. determine by how much the user has dragged
        guard let bestInterceptPoint = self.closestPointOnSliderCenterTrack(touchLocation) else {
            self.previousTouchPoint = touchLocation
            return nil
        }
        
        self.previousTouchPoint = touchLocation
        var mappedIntercept = self.mapScreenPointToSliderCenterTrackPoint(bestInterceptPoint)
        if (mappedIntercept.x > self.radiusClockCenterToSliderTrackCenter) {
            mappedIntercept = CGPoint(x: self.radiusClockCenterToSliderTrackCenter, y: mappedIntercept.y)
        }
        else if (mappedIntercept.x < -self.radiusClockCenterToSliderTrackCenter) {
            mappedIntercept = CGPoint(x: -self.radiusClockCenterToSliderTrackCenter, y: mappedIntercept.y)
        }
        
        if (mappedIntercept.y > self.radiusClockCenterToSliderTrackCenter) {
            mappedIntercept = CGPoint(x: mappedIntercept.x, y: self.radiusClockCenterToSliderTrackCenter)
        }
        else if (mappedIntercept.y < -self.radiusClockCenterToSliderTrackCenter) {
            mappedIntercept = CGPoint(x: mappedIntercept.x, y: -self.radiusClockCenterToSliderTrackCenter)
        }
        return mappedIntercept
    }
    
    public func translateSliderCenterPointToAngle(_ cartesianCoordinatePoint: CGPoint) -> CGFloat {
        let angle = self.clockFaceAngle(cartesianCoordinatePoint)
        if (angle.isNaN) {
            // try this calculation again
            let garbage = self.clockFaceAngle(cartesianCoordinatePoint)
            print("\(garbage)")
            return 0
        }
        return angle
    }
    
    public func translateAngleToClockFaceTime(_ angle: CGFloat) -> ClockFaceTime {
        // angle = (minutes / ticksPerRevolution) * 2 * Pi
        // angle / (2 * Pi) = (minutes / ticksPerRevolution)
        // minutes = (angle * ticksPerRevolution) / (2 * Pi)
        let rawMinutes = (angle * CGFloat(self.ticksPerRevolution)) / CGFloat(2 * Double.pi)
        let numberOfTicks: Int = Int(rawMinutes)
        
        // 4. Clock Face Time: e.g. 1:30am = 90 minutes
        // The angle is converted to raw minutes which the hour hand should lie on the clock face.
        // This position of the hour hand is different between 12-hour clocks and 24-hour clocks.
        // For 12-hour clocks, this time can only be a number between 0 minutes and 720 minutes (12 * 60).
        // Both AM and PM will show the same clock face time.
        let clockFaceTime: ClockFaceTime = ClockFaceTime(minutes: numberOfTicks, amORpm: DayOrNight.am, clockType: self.clockType)
        return clockFaceTime
    }
    
    public mutating func adjustStartAndEndTimesDuringTracking(location: CGPoint, highlightedKnob: HighlightedKnob) {
        //1. Screen Point:  e.g. (x=200, y=75)
        //The user's drag is reported in absolute screen coordinates.
        let screenPoint: CGPoint = location
        
        
        //2. Slider Centre Point: e.g. (x=60, y=60)
        //The screen point is converted to a point along the centre of the slider track,
        //using the centre of the clock face as (0,0) instead of the view's upper left corner.
        guard let sliderCenterPoint = translateTouchLocationToSliderCenterPoint(screenPoint) else {
            return print("Could not translate touch location to slider center point")
        }
        
        //3. Angle: e.g. 0.785 radians
        //The point in the centre of the slider track is converted to an angle,
        //the angle between the vertical line (12 o'clock) and the intercept to the slider centre point.
        let angle = self.clockFaceAngle(sliderCenterPoint)
        
        //5. Clock Face Time: e.g. 1:30am = 90 minutes
        //The angle is converted to raw minutes which the hour hand should lie on the clock face.
        //This position of the hour hand is different between 12-hour clocks and 24-hour clocks.
        //For 12-hour clocks, this time can only be a number between 0 minutes and 720 minutes (12 * 60).
        //Both AM and PM will show the same clock face time.
        let clockFaceTime = self.translateAngleToClockFaceTime(angle)
        
        //6. Time of Day Time: e.g. 1:30pm, or 13:30 = 810 minutes
        //For a 24-hour clock, the time of day is always the same as the clock face time.
        //But for a 12-hour clock, the time of day is only the same as the clock face time before noon.
        //After noon, the actual time of day is 12 hours greater.
        //For example, 1:30 on the clock is 13:30 of actual time.
        //In order to perform this calculation, more than just the Clock Face Time and clock type are
        //needed. The old time of day is also needed as it must be determined if a change from am to pm
        //is required or not.
        switch highlightedKnob {
        case .start:
            self.sliderViewModel.changeStartTimeOfDayUsingClockFaceTime(clockFaceTime)
        case .finish:
            self.sliderViewModel.changeFinishTimeOfDayUsingClockFaceTime(clockFaceTime)
        }
    }
}
