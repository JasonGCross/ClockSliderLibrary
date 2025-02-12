//
//  ClockQuadrant.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

/**
 Assumes a cartesian coordinate system, with an x and y axis, and the origin at (0, 0).
 The first quadrant is positive for both x and y.
 The second quadrant is positive x, negative y.
 The third quadrant is negative for both x and y.
 The fourth quadrant is negative x, but positive y.
 */
public enum ClockQuadrant: String {
    case first, second, third, fourth
}

extension ClockQuadrant {
    /**
     Takes a cartesian coordinate system point and maps it to one of four quadrants.
     
     - parameter point: the point to be mapped -- origin must be at (0, 0)
     - returns: the quadrant that this point lies within.
     */
    static func mapPointToQuadrant(_ point: CGPoint) -> ClockQuadrant {
        if (point.x >= 0) {
            if  (point.y >= 0) {
                return ClockQuadrant.first
            }
            else {
                return ClockQuadrant.second
            }
        }
        else {
            if (point.y >= 0) {
                return ClockQuadrant.fourth
            }
        }
        return ClockQuadrant.third
    }
    
    /**
     Takes time of day  as it would appear on a clock face (either a 12-hour clock or a 24-hour clock).
     This assumes that the clock functions by moving the hour hand a fraction for each minute of time passed.
     In other words, the hour hand is not locked to descrete places aligning with each whole hour.
     
     - parameter time: the time of day which is represented on the clock face
     - parameter clockType: the type of clock -- either 12-hour or 24 hour
     - returns: the quadrant that the hour hand lies within,
     */
    static func mapTimeToQuandrant(_ time: TimeOfDayModel, clockType: ClockType) -> ClockQuadrant {
        
        let oneRotation = clockType.rawValue * 60
        let halfRotation = clockType.rawValue * 30
        let quarterRotation = clockType.rawValue * 15
        let threeQuarterRotation = clockType.rawValue * 45
        
        let totalMinutes = time.totalMinutes
        var safeMinutes: Int = totalMinutes
        if (totalMinutes >= oneRotation) {
            safeMinutes = oneRotation * (totalMinutes / oneRotation)
        }
        // due to the constructor of TimeOfDayModel, negative minutes are never possible
        
        if (safeMinutes >= 0) && (safeMinutes < quarterRotation) {
            return ClockQuadrant.first
        }
        else if (safeMinutes >= quarterRotation) && (safeMinutes < halfRotation) {
            return ClockQuadrant.second
        }
        else if (safeMinutes >= halfRotation) && (safeMinutes < threeQuarterRotation) {
            return ClockQuadrant.third
        }
        else {
            return ClockQuadrant.fourth
        }
    }
}

