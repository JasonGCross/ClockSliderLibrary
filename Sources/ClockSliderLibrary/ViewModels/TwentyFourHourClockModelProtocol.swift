//
//  TwentyFourHourClockModelProtocol.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

protocol TwentyFourHourClockModelProtocol: TimeRangeSliderControlViewModelProtocol {
}

extension TwentyFourHourClockModelProtocol {
    mutating func incrementDuration(minutes: Int) {
        self.finishTimeInMinutes = minutes
        if (minutes >= oneRotation) {
            self.advanceRotationCountIfAllowed()
        }
    }
}
