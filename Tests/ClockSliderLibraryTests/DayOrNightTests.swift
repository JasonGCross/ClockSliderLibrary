//
//  DayOrNightTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-23.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct DayOrNightTests {
    @Test
    func validateInstantiation() throws {
        let model1 = DayOrNight.am
        #expect(model1.rawValue == "AM")
        
        let model2 = DayOrNight.pm
        #expect(model2.rawValue == "PM")
        
        let model3 = DayOrNight(rawValue: "xyz")
        #expect(model3 == nil)
    }
    
    @Test
    func validateSwitchingFromDayToNight() throws {
        var model = DayOrNight.am
        model.switchDaylightDescription()
        #expect(model == .pm)
        
        model.switchDaylightDescription()
        #expect(model == .am)
        
        var model2 = DayOrNight.pm
        model2.switchDaylightDescription()
        model2.switchDaylightDescription()
        #expect(model2 == .pm)
    }
}
