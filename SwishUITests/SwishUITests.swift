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
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testFoundationLaunches() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.staticTexts["Swish"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["home.timer.countdown"].exists)
    }

    @MainActor
    func testTimerStartsPausesAndResumes() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.buttons["Start focus"].waitForExistence(timeout: 3))
        app.buttons["Start focus"].tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 2))
        app.buttons["Pause"].tap()

        XCTAssertTrue(app.buttons["Resume"].waitForExistence(timeout: 2))
        app.buttons["Resume"].tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Cancel timer"].exists)
    }

    @MainActor
    func testCreatesAndCompletesTask() throws {
        let app = makeApp(showTasks: true)
        app.launch()

        XCTAssertTrue(app.buttons["tasks.add"].waitForExistence(timeout: 2))
        app.buttons["tasks.add"].tap()

        let titleField = app.textFields["tasks.editor.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Project roadmap")
        app.buttons["tasks.editor.save"].tap()

        let editButton = app.buttons["Edit Project roadmap"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))

        let completeButton = app.buttons["Mark Project roadmap complete"]
        XCTAssertTrue(completeButton.exists)
        completeButton.tap()

        XCTAssertTrue(app.buttons["Reopen Project roadmap"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testStartsFocusFromTaskAndOpensHome() throws {
        let app = makeApp(showTasks: true)
        app.launch()

        createTask(named: "Project roadmap", in: app)

        let startButton = app.buttons["Start focus on Project roadmap"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["home.currentTask"].exists)
        XCTAssertEqual(
            app.descendants(matching: .any)["home.currentTask"].label,
            "Working on Project roadmap"
        )
    }

    @MainActor
    func testSelectsTaskFromHomeForNextFocusSession() throws {
        let app = makeApp(showTasks: true)
        app.launch()

        createTask(named: "Design landing page", in: app)
        app.tabBars.buttons["Home"].tap()

        let taskSelector = app.buttons["home.taskSelector"]
        XCTAssertTrue(taskSelector.waitForExistence(timeout: 2))
        taskSelector.tap()

        let taskChoice = app.buttons["Select Design landing page"]
        XCTAssertTrue(taskChoice.waitForExistence(timeout: 2))
        taskChoice.tap()

        XCTAssertEqual(taskSelector.label, "Working on Design landing page")
        app.buttons["Start focus"].tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.descendants(matching: .any)["home.currentTask"].label,
            "Working on Design landing page"
        )
    }

    @MainActor
    func testStatsScreenSwitchesPeriodsAndShowsEmptyHistory() throws {
        let app = makeApp(showStats: true)
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["stats.screen"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["stats.focusTime.value"].label, "0m")
        XCTAssertEqual(app.staticTexts["stats.sessions.value"].label, "0")
        XCTAssertEqual(app.staticTexts["stats.tasks.value"].label, "0")

        let periodPicker = app.segmentedControls["stats.period"]
        XCTAssertTrue(periodPicker.waitForExistence(timeout: 2))
        periodPicker.buttons["Month"].tap()
        XCTAssertTrue(periodPicker.buttons["Month"].isSelected)

        app.swipeUp()
        XCTAssertTrue(
            app.descendants(matching: .any)["stats.categories.empty"]
                .waitForExistence(timeout: 2)
        )
    }

    @MainActor
    func testOpensFocusHistoryFromStats() throws {
        let app = makeApp(showStats: true)
        app.launch()

        let historyButton = app.buttons["stats.history"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 2))
        historyButton.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["history.screen"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertEqual(app.staticTexts["history.focusTime.value"].label, "0m")
        XCTAssertEqual(app.staticTexts["history.sessions.value"].label, "0")
        XCTAssertEqual(app.staticTexts["history.tasks.value"].label, "0")

        app.swipeUp()
        XCTAssertTrue(
            app.descendants(matching: .any)["history.empty"]
                .waitForExistence(timeout: 2)
        )
    }

    @MainActor
    func testChangesSettingsPreferences() throws {
        let app = makeApp(showSettings: true)
        app.launch()

        XCTAssertTrue(
            app.descendants(matching: .any)["settings.screen"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["settings.focusDuration"].exists
        )

        let autoStartBreaks = app.switches["settings.autoStartBreaks"]
        XCTAssertTrue(autoStartBreaks.exists)
        XCTAssertEqual(autoStartBreaks.value as? String, "Off")
        tapSwitch(autoStartBreaks)
        XCTAssertTrue(waitForValue("On", of: autoStartBreaks))

        let sounds = app.switches["settings.sound"]
        XCTAssertTrue(sounds.exists)
        XCTAssertEqual(sounds.value as? String, "On")
        tapSwitch(sounds)
        XCTAssertTrue(waitForValue("Off", of: sounds))
    }

    private func createTask(named title: String, in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["tasks.add"].waitForExistence(timeout: 2))
        app.buttons["tasks.add"].tap()

        let titleField = app.textFields["tasks.editor.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText(title)
        app.buttons["tasks.editor.save"].tap()

        XCTAssertTrue(app.buttons["Edit \(title)"].waitForExistence(timeout: 2))
    }

    private func waitForValue(
        _ value: String,
        of element: XCUIElement,
        timeout: TimeInterval = 2
    ) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func tapSwitch(_ element: XCUIElement) {
        element.coordinate(
            withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)
        ).tap()
    }

    private func makeApp(
        showTasks: Bool = false,
        showStats: Bool = false,
        showSettings: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        if showTasks {
            app.launchArguments.append("--ui-testing-show-tasks")
        }
        if showStats {
            app.launchArguments.append("--ui-testing-show-stats")
        }
        if showSettings {
            app.launchArguments.append("--ui-testing-show-settings")
        }
        return app
    }
}
