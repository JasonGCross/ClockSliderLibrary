//
//  ClockType.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-21.
//

/**
  A clock type describes how many ticks (hours) are on a clock face.
 */
public enum ClockType: Int {
    /// 12-hour clocks only go from 1 to 12
    case twelveHourClock = 12
    
    /// 24-hour clocks go from 1 to 24 (with 12 in what is normally the 6 o'clock position)
    case twentyFourHourClock = 24
}

public extension ClockType {
    
    /**
     Gives the number of  minutes are represented by the minute hand moving 360 degrees
     (from any hour such as 3, and then returning to the same hour).
     */
    func minutesPerRevolution() -> Int {
        return 60 * self.rawValue
    }
    
    /**
     Gives the number of minutes represented by the arc (pie slice) with the angle passed in.
    - Parameter angle: the angle the minute hand has moved.
     */
    func minutesFromAngle(_ angle: Double) -> Double {
        // 1 clock revolution is equivalent to 2_PI
        let numberOfMinutesPerRevolution: Double = Double(self.minutesPerRevolution())
        
        var result = (angle / (2.0 * Double.pi)) * numberOfMinutesPerRevolution
        result = result.truncatingRemainder(dividingBy: numberOfMinutesPerRevolution)
        return result
    }
}
