//
//  ClockQuadrantTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-22.
//

import Foundation
import Testing
@testable import ClockSliderLibrary

struct ClockQuadrantTests {
    @Test
    func validateInstantiation() throws {
        let clockQuandrant1 = ClockQuadrant.first
        #expect(clockQuandrant1.rawValue == "first")
        
        let clockQuandrant2 = ClockQuadrant.second
        #expect(clockQuandrant2.rawValue == "second")
        
        let clockQuandrant3 = ClockQuadrant.third
        #expect(clockQuandrant3.rawValue == "third")
        
        let clockQuandrant4 = ClockQuadrant.fourth
        #expect(clockQuandrant4.rawValue == "fourth")
        
        let clockQuadrant5 = ClockQuadrant(rawValue: "fifth")
        #expect(nil == clockQuadrant5)
    }
    
    @Test(arguments: [
        (x: 1.0,   y: 1.0,   expectedResult: ClockQuadrant.first.rawValue),
        (x: -1.0,  y: 1.0,   expectedResult: ClockQuadrant.fourth.rawValue),
        (x: 1.0,   y: -1.0,  expectedResult: ClockQuadrant.second.rawValue),
        (x: -1.0,  y: -1.0,  expectedResult: ClockQuadrant.third.rawValue),
    ]) func validateMappingPointToQuadrant(
        tuple: (x: CGFloat, y: CGFloat, expectedResult: String)
    ) {
        let point = CGPoint(x: tuple.x, y: tuple.y)
        let result = ClockQuadrant.mapPointToQuadrant(point)
        #expect(result.rawValue == tuple.expectedResult)
    }
}
