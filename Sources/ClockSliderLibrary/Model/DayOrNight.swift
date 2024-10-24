//
//  DayOrNight.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

public enum DayOrNight: String {
    case am = "AM"
    case pm = "PM"
}

extension DayOrNight {
    mutating func switchDaylightDescription() {
        if (self == .am) {
            self = .pm
        }
        else {
            self = .am
        }
    }
}
