//
//  ClockRotationCountTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

@Suite struct ClockRotationCountTests {
    
    @Test(arguments: [
        (initialCount: 0, expectedResult: 1),
        (initialCount: 1, expectedResult: 1)
    ]) func validateIncrementingRotation(
        tuple: (initialCount: Int, expectedResult: Int)
    ) throws {
        let model = ClockRotationCount(rawValue: tuple.initialCount)
        try #require(nil != model)
        var safeModel = model!
        
        safeModel.incrementCount()
        let result = safeModel.rawValue
        #expect(result == tuple.expectedResult)
        
        // try another rotation in the same direction
        safeModel.incrementCount()
        let result2 = safeModel.rawValue
        #expect(result2 == tuple.expectedResult)
    }
    
    @Test(arguments: [
        (initialCount: 0, expectedResult: 0),
        (initialCount: 1, expectedResult: 0)
    ]) func validateDecrementingRotation(
        tuple: (initialCount: Int, expectedResult: Int)
    ) throws {
        let model = ClockRotationCount(rawValue: tuple.initialCount)
        try #require(nil != model)
        var safeModel = model!
        
        safeModel.decrementCount()
        let result = safeModel.rawValue
        #expect(result == tuple.expectedResult)
        
        // try another rotation in the same direction
        safeModel.decrementCount()
        let result2 = safeModel.rawValue
        #expect(result2 == tuple.expectedResult)
    }
}
