//
//  YatraiPlannerUITests.swift
//  YatraiPlannerUITests
//
//  Created by Ganesh Raman on 17/01/26.
//

import XCTest

final class YatraiPlannerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTripInputsVisible() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE")
        app.launch()

        XCTAssertTrue(app.navigationBars["Trip inputs"].exists)
        XCTAssertTrue(app.textFields["Starting city"].exists)
    }

    @MainActor
    func testGenerateItineraryShowsDraft() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE")
        app.launch()

        app.buttons["Generate Itinerary"].tap()
        XCTAssertTrue(app.navigationBars["Itinerary draft"].waitForExistence(timeout: 5))
    }
}
