//
//  SingleHandedClockModelProtocol.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

protocol TimeSlice1HandClockProtocol: TimeSliceViewModelProtocol {
}

extension TimeSlice1HandClockProtocol {
    var startTimeInMinutes: Int {
        set {
            
        }
        get {
            return 0
        }
    }
    
    var finishTimeInMinutes: Int {
        set {
            let safeMinutes = TimeSliceViewModel1Hand12HourClock.convertMinutesToSafeMinutes(newValue, clockType: self.clockType)
            let timeModel = TimeOfDayModel.timeModelFromMinutes(safeMinutes)
            self.finishTime.quadrant = ClockQuadrant.mapTimeToQuandrant(timeModel, clockType: self.clockType)
            
            // decide whether or not we are changing between a single or double clock rotation
            // note that this decision may happen at any clock position for either hand
            let oldTimeRange = TimeSliceViewModel1Hand12HourClock.timeSpanBetween(self.startTime.minute,
                                                                          finishTime: self.finishTime.minute)
            let newTimeRange = TimeSliceViewModel1Hand12HourClock.timeSpanBetween(self.startTime.minute,
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
