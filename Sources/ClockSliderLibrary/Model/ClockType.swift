//
//  ClockType.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-21.
//

public enum ClockType: Int {
    case twelveHourClock = 12
    case twentyFourHourClock = 24
}

public extension ClockType {
    func minutesPerRevolution() -> Int {
        return 60 * self.rawValue
    }
    
    
    func minutesFromAngle(_ angle: Double) -> Double {
        // 1 clock revolution is equivalent to 2_PI
        let numberOfMinutesPerRevolution: Double = Double(self.minutesPerRevolution())
        
        var result = (angle / (2.0 * Double.pi)) * numberOfMinutesPerRevolution
        result = result.truncatingRemainder(dividingBy: numberOfMinutesPerRevolution)
        return result
    }
}
