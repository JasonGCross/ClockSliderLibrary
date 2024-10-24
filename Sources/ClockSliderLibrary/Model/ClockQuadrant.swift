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
}

