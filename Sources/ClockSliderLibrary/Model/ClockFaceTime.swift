//
//  ClockFaceTime.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Foundation

public struct ClockFaceTime: Equatable {
    var minutes: Int = 0
    var amORpm: DayOrNight = .am
    var clockType: ClockType = .twelveHourClock
    
    /**
     Takes time of day  as it would appear on a clock face (either a 12-hour clock or a 24-hour clock).
     This assumes that the clock functions by moving the hour hand a fraction for each minute of time passed.
     In other words, the hour hand is not locked to descrete places aligning with each whole hour.
     
     - returns: the quadrant that the hour hand lies within
     */
    var quadrant: ClockQuadrant {
        let halfRotation = clockType.rawValue * 30
        let quarterRotation = clockType.rawValue * 15
        let threeQuarterRotation = clockType.rawValue * 45
        
        if (minutes >= 0) && (minutes < quarterRotation) {
            return ClockQuadrant.first
        }
        else if (minutes >= quarterRotation) && (minutes < halfRotation) {
            return ClockQuadrant.second
        }
        else if (minutes >= halfRotation) && (minutes < threeQuarterRotation) {
            return ClockQuadrant.third
        }
        else {
            return ClockQuadrant.fourth
        }
    }
    
    static public func ==(lhs: ClockFaceTime, rhs: ClockFaceTime) -> Bool {
        let areEqual = (lhs.minutes == rhs.minutes) &&
        lhs.amORpm == rhs.amORpm
        
        return areEqual
    }
}
