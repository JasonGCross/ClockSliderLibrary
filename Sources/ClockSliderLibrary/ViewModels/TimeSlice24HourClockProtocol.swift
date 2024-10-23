//
//  TwentyFourHourClockModelProtocol.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

protocol TimeSlice24HourClockProtocol: TimeSliceViewModelProtocol {
}

extension TimeSlice24HourClockProtocol {
    mutating func incrementDuration(minutes: Int) {
        self.finishTimeInMinutes = minutes
        if (minutes >= oneRotation) {
            self.advanceRotationCountIfAllowed()
        }
    }
}
