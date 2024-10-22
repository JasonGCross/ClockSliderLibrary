//
//  ClockRotationCount.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

public enum ClockRotationCount: Int {
    case first
    case second
    
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

