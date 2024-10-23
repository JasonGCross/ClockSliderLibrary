//
//  SingleHandedClockModelProtocol.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

protocol SingleHandedClockModelProtocol: TimeRangeSliderControlViewModelProtocol {
}

extension SingleHandedClockModelProtocol {
    var startTimeInMinutes: Int {
        set {
            
        }
        get {
            return 0
        }
    }
    
    var finishTimeInMinutes: Int {
        set {
            let safeMinutes = SingleHand12HourClockModel.convertMinutesToSafeMinutes(newValue, clockType: self.clockType)
            
            self.finishTime.quadrant = ClockQuadrant.mapMinutesToQuandrant(safeMinutes, clockType: self.clockType)
            
            // decide whether or not we are changing between a single or double clock rotation
            // note that this decision may happen at any clock position for either hand
            let oldTimeRange = SingleHand12HourClockModel.timeSpanBetween(self.startTime.minute,
                                                                          finishTime: self.finishTime.minute)
            let newTimeRange = SingleHand12HourClockModel.timeSpanBetween(self.startTime.minute,
                                                                          finishTime: safeMinutes)
            self.changeRotationCountIfNeeded(oldTimeRange,
                                             newTimeRange: newTimeRange)
            
            self.finishTime.setMinutes(safeMinutes)
        }
        get {
            return self.finishTime.minute
        }
    }
}
