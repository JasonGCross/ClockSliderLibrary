import Testing
import Foundation
@testable import ClockSliderLibrary

@Suite struct TimeOnlyModelTests {
    
    @Test(arguments: [
        // no overflow
        (hour: 0, min: 0, add: 0, expectedHour: 0, expectedMin: 0),
        (hour: 0, min: 1, add: 1, expectedHour: 0, expectedMin: 2),
        // overflow
        (hour: 0, min: 1, add: 61, expectedHour: 1, expectedMin: 2),
        (hour: 0, min: 0, add: 60, expectedHour: 1, expectedMin: 0),
        (hour: 3, min: 3, add: 63, expectedHour: 4, expectedMin: 6),
        // negative minutes
        (hour: 0, min: 0, add: -1, expectedHour: 23, expectedMin: 59),
        (hour: 0, min: 30, add: -20, expectedHour: 0, expectedMin: 10),
        (hour: 3, min: 0, add: -90, expectedHour: 1, expectedMin: 30),
        // days of overflow
        (hour: 0, min: 0, add: 1440, expectedHour: 0, expectedMin: 0),
        (hour: 0, min: 0, add: 1441, expectedHour: 0, expectedMin: 1),
        (hour: 23, min: 59, add: 2880, expectedHour: 23, expectedMin: 59),
        (hour: 23, min: 59, add: 2882, expectedHour: 0, expectedMin: 1),
        (hour: 0, min: 0, add: -1441, expectedHour: 23, expectedMin: 59),
    ])
    func testAddingTimeInterval(
        tuple: (hour: Int, min: Int, add: TimeInterval, expectedHour: Int, expectedMin: Int)
    ) {
        let timeOnly = TimeOfDayModel(hour: tuple.hour, minute: tuple.min)
        let result = timeOnly.addingTimeInterval(60 * tuple.add)
        let expectedResult = TimeOfDayModel(hour: tuple.expectedHour, minute: tuple.expectedMin)
        #expect(result == expectedResult)
    }
    
    @Test(arguments: [
        // no overflow
        (initialHour: 0,  initialMin: 0,  setMin: 10    ,expectedHour: 0  ,expectedMin: 10 ),
        // overflow
        (initialHour: 0,  initialMin: 0,  setMin: 60    ,expectedHour: 1  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 0,  setMin: 75    ,expectedHour: 1  ,expectedMin: 15),
        (initialHour: 23, initialMin: 59, setMin: 2     ,expectedHour: 23  ,expectedMin: 2 ),
        // negative minutes
        (initialHour: 0,  initialMin: 0,  setMin: -10   ,expectedHour: 23 ,expectedMin: 50),
        // days of overflow
        (initialHour: 0,  initialMin: 0,  setMin: 1440  ,expectedHour: 0  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 0,  setMin: 1441  ,expectedHour: 0  ,expectedMin: 1 ),
        (initialHour: 23, initialMin: 59, setMin: 2880  ,expectedHour: 23 ,expectedMin: 0),
         (initialHour: 23, initialMin: 59, setMin: 2882  ,expectedHour: 23  ,expectedMin: 2 ),
        (initialHour: 0,  initialMin: 0,  setMin: -1441 ,expectedHour: 23 ,expectedMin: 59),
    ])
    func setMinutes(
        tuple: (initialHour: Int, initialMin: Int, setMin: Int, expectedHour: Int, expectedMin: Int)
    ) {
        var timeOnly = TimeOfDayModel(hour: tuple.initialHour, minute: tuple.initialMin)
        timeOnly.setMinutes(tuple.setMin)
        #expect(timeOnly.hour == tuple.expectedHour)
        #expect(timeOnly.minute == tuple.expectedMin)
    }
    
    @Test(arguments: [
        // no overflow
        (initialHour: 0, initialMin: 0,   setHour: 10    ,expectedHour: 10 ,expectedMin: 0),
        // days of overflow
        (initialHour: 0,  initialMin: 0,  setHour: 24  ,expectedHour: 0  ,expectedMin: 0 ),
        (initialHour: 0,  initialMin: 1,  setHour: 25  ,expectedHour: 1  ,expectedMin: 1 ),
        (initialHour: 23, initialMin: 59, setHour: 48  ,expectedHour: 0  ,expectedMin: 59),
        (initialHour: 0,  initialMin: 59, setHour: 47  ,expectedHour: 23 ,expectedMin: 59),
        (initialHour: 11, initialMin: 0,  setHour: -24 ,expectedHour: 0 ,expectedMin: 0),
    ])
    func setHours(
        tuple: (initialHour: Int, initialMin: Int, setHour: Int, expectedHour: Int, expectedMin: Int)
    ) {
        var timeOnly = TimeOfDayModel(hour: tuple.initialHour, minute: tuple.initialMin)
        timeOnly.setHours(tuple.setHour)
        #expect(timeOnly.hour == tuple.expectedHour)
        #expect(timeOnly.minute == tuple.expectedMin)
    }
}
