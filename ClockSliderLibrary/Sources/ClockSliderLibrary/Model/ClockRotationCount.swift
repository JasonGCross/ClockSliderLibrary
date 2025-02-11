//
//  ClockRotationCount.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

/**
 An abstract idea to keep track of how many times someone "goes around" a circular clock face.
 The user slides his finger (or mouse) in a circular arc around a clock. Any new dragging is the first time
 (rotation count = first). If the user continues dragging through the initial drag position (more than a 360
 degree rotation), then the count increments (rotation count = second).
 The count can never be more than 2. If the user keeps dragging past the second count, the count
 remains at the second.
 */
public enum ClockRotationCount: Int {
    /**
     The user's circular arc motion caused by dragging is between 0 and 360 degrees.
     */
    case first
    /**
     The user's circular arc motion caused by dragging is greater than 360 degrees.
     */
    case second
    
}

extension ClockRotationCount {
    mutating func incrementCount() {
        if (self == .first) {
            self = .second
        }
    }
    
    mutating func decrementCount() {
        if (self == .second) {
            self = .first
        }
    }
}

