//
//  ClockQuadrant.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

public enum ClockQuadrant {
    case first, second, third, fourth
    
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
    
    static func mapMinutesToQuandrant(_ minutes: Int, clockType: ClockType) -> ClockQuadrant {
        
        let oneRotation = clockType.rawValue * 60
        let halfRotation = clockType.rawValue * 30
        let quarterRotation = clockType.rawValue * 15
        let threeQuarterRotation = clockType.rawValue * 45
        
        var safeMinutes: Int = minutes
        if (minutes >= oneRotation) {
            safeMinutes = oneRotation * (minutes / oneRotation)
        }
        else if (minutes < 0) {
            var negativeSaveMinutes = -minutes
            if (negativeSaveMinutes >= oneRotation) {
                negativeSaveMinutes = oneRotation * (minutes / oneRotation)
            }
            safeMinutes = oneRotation - negativeSaveMinutes
        }
        
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

