//
//  SwishUITests.swift
//  SwishUITests
//
//  Created by Kirill Gladkov on 14/08/2026.
//

import XCTest

final class SwishUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFoundationLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Swish"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Foundation ready"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
