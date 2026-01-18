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

        XCTAssertTrue(app.navigationBars["Trip basics"].exists)
        XCTAssertTrue(app.textFields["Starting city"].exists)
    }

    @MainActor
    func testGenerateItineraryShowsDraft() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE")
        app.launch()

        while app.buttons["Next"].exists {
            app.buttons["Next"].tap()
        }

        app.buttons["Generate Itinerary"].tap()
        XCTAssertTrue(app.navigationBars["Trip outputs"].waitForExistence(timeout: 5))
        app.staticTexts["Itinerary"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Itinerary draft"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBreadcrumbNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE")
        app.launch()

        app.buttons["Next"].tap()
        app.buttons["Next"].tap()

        let basics = app.buttons["breadcrumb-Basics"]
        XCTAssertTrue(basics.exists)
        basics.tap()
        XCTAssertTrue(app.navigationBars["Trip basics"].exists)
    }

    @MainActor
    func testMapPreviewVisible() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE")
        app.launch()

        while app.buttons["Next"].exists {
            app.buttons["Next"].tap()
        }

        app.buttons["Generate Itinerary"].tap()
        XCTAssertTrue(app.navigationBars["Trip outputs"].waitForExistence(timeout: 5))
        app.staticTexts["Itinerary"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Itinerary draft"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["map-preview-0"].waitForExistence(timeout: 5))
    }
}
