//
//  clock_slider_viewUITests.swift
//  clock_slider_viewUITests
//
//  Created by Jason Cross on 2024-05-08.
//  Copyright © 2024 Cross Swim Training, Inc. All rights reserved.
//

import XCTest

final class clock_slider_viewUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
                app.launch()
        
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.swipeRight()
        
        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["5 min"]/*[[".segmentedControls.buttons[\"5 min\"]",".buttons[\"5 min\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["10 min"]/*[[".segmentedControls.buttons[\"10 min\"]",".buttons[\"10 min\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.staticTexts["08:00"].tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
