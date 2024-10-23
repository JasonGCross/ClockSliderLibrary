//
//  DoubleHandedClockModelProtocol.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

protocol DoubleHandedClockModelProtocol: TimeRangeSliderControlViewModelProtocol {
}

extension DoubleHandedClockModelProtocol {
    var startTimeInMinutes: Int {
        set {
            let safeMinutes = SingleHand12HourClockModel.convertMinutesToSafeMinutes(newValue, clockType: self.clockType)
            let timeModel = TimeOfDayModel.timeModelFromMinutes(safeMinutes)
            
            // decide whether or not this single hand represents daytime or night time
            // note that this decision depends explicitly on the 12 o'clock position
            let newQuadrant = ClockQuadrant.mapTimeToQuandrant(timeModel, clockType: self.clockType)
            if (newQuadrant != self.startTime.quadrant) {
                if ((newQuadrant == .fourth) && (self.startTime.quadrant == .first)) {
                    self.startTime = self.startTime.addingTimeInterval(12 * 60 * 60)
                }
                else if ((newQuadrant == .first) && (self.startTime.quadrant == .fourth)) {
                    self.startTime = self.startTime.addingTimeInterval(-12 * 60 * 60)
                }
                self.startTime.quadrant = newQuadrant
            }
            
            // decide whether or not we are changing between a single or double clock rotation
            // note that this decision may happen at any clock position for either hand
            let oldTimeRange = SingleHand12HourClockModel.timeSpanBetween(self.startTime.minute,
                                                                          finishTime: self.finishTime.minute)
            let newTimeRange = SingleHand12HourClockModel.timeSpanBetween(safeMinutes,
                                                                          finishTime: self.finishTime.minute)
            self.changeRotationCountIfNeeded(oldTimeRange,
                                             newTimeRange: newTimeRange)
            
            self.finishTime.setMinutes(safeMinutes)
        }
        get {
            return self.startTime.minute
        }
    }
    
    var finishTimeInMinutes: Int {
        set {
            let safeMinutes = SingleHand12HourClockModel.convertMinutesToSafeMinutes(newValue, clockType: self.clockType)
            let timeModel = TimeOfDayModel.timeModelFromMinutes(safeMinutes)
            
            // decide whether or not this single hand represents daytime or night time
            // note that this decision depends explicitly on the 12 o'clock position
            let newQuadrant = ClockQuadrant.mapTimeToQuandrant(timeModel, clockType: self.clockType)
            if (newQuadrant != self.finishTime.quadrant) {
                if ((newQuadrant == .fourth) && (self.finishTime.quadrant == .first)) {
                    self.finishTime = self.finishTime.addingTimeInterval(12 * 60 * 60)
                }
                else if ((newQuadrant == .first) && (self.finishTime.quadrant == .fourth)) {
                    self.finishTime = self.finishTime.addingTimeInterval(-12 * 60 * 60)
                }
                self.finishTime.quadrant = newQuadrant
            }
            
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
    
    mutating func setInitialDuration(minutes: Int) {
        self.incrementDuration(minutes: minutes)
    }
}
