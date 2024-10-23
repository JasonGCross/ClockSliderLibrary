//
//  ClockTypeTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct ClockTypeTests {
    @Test
    func validateInstantiation() throws {
        let clockType1 = ClockType.twelveHourClock
        #expect(clockType1.rawValue == 12)
        
        let clockType2 = ClockType.twentyFourHourClock
        #expect(clockType2.rawValue == 24)
        
        let clockType3 = ClockType(rawValue: 6)
        #expect(nil == clockType3)
    }
}
