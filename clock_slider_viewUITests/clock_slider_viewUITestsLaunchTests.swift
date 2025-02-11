//
//  clock_slider_viewUITestsLaunchTests.swift
//  clock_slider_viewUITests
//
//  Created by Jason Cross on 2024-05-08.
//  Copyright © 2024 Cross Swim Training, Inc. All rights reserved.
//

import XCTest

final class clock_slider_viewUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
