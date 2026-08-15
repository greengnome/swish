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
    func testCompletesOnboardingOnlyOnce() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-reset-onboarding",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]
        app.launch()

        let focusTitle = app.staticTexts["onboarding.focus.title"]
        XCTAssertTrue(focusTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(
            app.buttons["onboarding.page.1"].value as? String,
            "Selected"
        )

        app.buttons["onboarding.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["onboarding.tasks.title"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertEqual(
            app.buttons["onboarding.page.2"].value as? String,
            "Selected"
        )

        app.buttons["onboarding.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["onboarding.insights.title"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertEqual(
            app.buttons["onboarding.page.3"].value as? String,
            "Selected"
        )
        XCTAssertEqual(app.buttons["onboarding.continue"].label, "Let's focus")

        app.buttons["onboarding.continue"].tap()

        XCTAssertTrue(
            app.staticTexts["home.timer.countdown"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertFalse(focusTitle.exists)

        app.terminate()
        app.launchArguments = [
            "--ui-testing",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["home.timer.countdown"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertFalse(focusTitle.exists)
    }

    @MainActor
    func testDisplaysOnboardingInUkrainian() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-reset-onboarding",
            "-AppleLanguages",
            "(uk)",
            "-AppleLocale",
            "uk_UA"
        ]
        app.launch()

        let focusTitle = app.staticTexts["onboarding.focus.title"]
        XCTAssertTrue(focusTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(focusTitle.label, "Зосереджуйтеся глибше")
        XCTAssertEqual(app.buttons["onboarding.continue"].label, "Продовжити")
        XCTAssertEqual(
            app.buttons["onboarding.page.1"].value as? String,
            "Вибрано"
        )

        app.buttons["onboarding.continue"].tap()
        let tasksTitle = app.staticTexts["onboarding.tasks.title"]
        XCTAssertTrue(tasksTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(tasksTitle.label, "Перетворюйте плани на прогрес")

        app.buttons["onboarding.continue"].tap()
        let insightsTitle = app.staticTexts["onboarding.insights.title"]
        XCTAssertTrue(insightsTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(insightsTitle.label, "Відстежуйте свій прогрес")
        XCTAssertEqual(
            app.buttons["onboarding.continue"].label,
            "Почати фокусування"
        )
    }

    @MainActor
    func testDisplaysDefaultCategoriesInUkrainian() throws {
        let app = makeApp(
            showTasks: true,
            language: "uk",
            locale: "uk_UA"
        )
        app.launch()

        XCTAssertTrue(app.buttons["Робота"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Особисте"].exists)
        XCTAssertTrue(app.buttons["Навчання"].exists)
        XCTAssertFalse(app.buttons["Work"].exists)
    }

    @MainActor
    func testUsesHomeInUkrainian() throws {
        let app = makeApp(language: "uk", locale: "uk_UA")
        app.launch()

        XCTAssertTrue(app.buttons["Почати фокус"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["home.settings"].label, "Налаштування")
        XCTAssertEqual(app.buttons["home.taskSelector"].label, "Вибрати завдання")
        XCTAssertTrue(app.staticTexts["Сьогодні"].exists)
        XCTAssertTrue(app.staticTexts["Сесії"].exists)
        XCTAssertTrue(app.staticTexts["Час фокусу"].exists)
        XCTAssertTrue(app.staticTexts["Виконано"].exists)
        XCTAssertTrue(app.tabBars.buttons["Головна"].isSelected)
        XCTAssertTrue(app.tabBars.buttons["Статистика"].exists)
        XCTAssertTrue(app.tabBars.buttons["Завдання"].exists)
        XCTAssertTrue(app.tabBars.buttons["Налаштування"].exists)

        app.buttons["home.taskSelector"].tap()
        XCTAssertTrue(app.navigationBars["Вибрати завдання"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Вибрати варіант без завдання"].exists)
        XCTAssertTrue(app.staticTexts["Немає активних завдань"].exists)
        app.buttons["Скасувати"].tap()

        app.tabBars.buttons["Завдання"].tap()
        createTask(named: "Design landing page", in: app)
        app.tabBars.buttons["Головна"].tap()

        app.buttons["home.taskSelector"].tap()
        let taskChoice = app.buttons["Вибрати: Design landing page"]
        XCTAssertTrue(taskChoice.waitForExistence(timeout: 2))
        taskChoice.tap()
        XCTAssertEqual(
            app.buttons["home.taskSelector"].label,
            "У роботі: Design landing page"
        )

        app.buttons["Почати фокус"].tap()
        XCTAssertTrue(app.buttons["Пауза"].waitForExistence(timeout: 2))
        app.buttons["Пауза"].tap()
        XCTAssertTrue(app.buttons["Продовжити"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["home.timer.cancel"].label, "Скасувати таймер")
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
    func testDisplaysRunningTimerOutsideApp() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.buttons["Start focus"].waitForExistence(timeout: 3))
        app.buttons["Start focus"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 2))

        XCUIDevice.shared.press(.home)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertTrue(
            springboard.wait(for: .runningForeground, timeout: 3),
            "Starting a timer should leave a running Live Activity visible outside Swish."
        )
        Thread.sleep(forTimeInterval: 2)

        let compactScreenshot = XCTAttachment(
            screenshot: XCUIScreen.main.screenshot()
        )
        compactScreenshot.name = "Running focus Live Activity — compact"
        compactScreenshot.lifetime = .keepAlways
        add(compactScreenshot)

        springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.04)
        ).press(forDuration: 1)

        XCTAssertTrue(
            springboard.staticTexts["Focus"].waitForExistence(timeout: 3),
            "Long-pressing the timer should reveal the expanded Live Activity."
        )

        let expandedScreenshot = XCTAttachment(
            screenshot: XCUIScreen.main.screenshot()
        )
        expandedScreenshot.name = "Running focus Live Activity — expanded"
        expandedScreenshot.lifetime = .keepAlways
        add(expandedScreenshot)
    }

    @MainActor
    func testOpensSettingsFromHomeToolbar() throws {
        let app = makeApp()
        app.launch()

        let settingsButton = app.buttons["home.settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["settings.screen"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.tabBars.buttons["Settings"].isSelected)
    }

    @MainActor
    func testOpensFocusHistoryFromHomeSummary() throws {
        let app = makeApp()
        app.launch()

        let viewAllButton = app.buttons["home.summary.viewAll"]
        XCTAssertTrue(viewAllButton.waitForExistence(timeout: 2))
        app.swipeUp()
        viewAllButton.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["history.screen"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected)
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
    func testUsesTasksInUkrainian() throws {
        let app = makeApp(
            showTasks: true,
            language: "uk",
            locale: "uk_UA"
        )
        app.launch()

        XCTAssertTrue(app.navigationBars["Завдання"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["tasks.add"].label, "Додати завдання")
        XCTAssertTrue(app.buttons["Усі"].exists)
        XCTAssertTrue(app.staticTexts["Завдань поки немає"].exists)
        XCTAssertTrue(app.buttons["Створити завдання"].exists)

        app.buttons["tasks.add"].tap()
        XCTAssertTrue(app.navigationBars["Нове завдання"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Завдання"].exists)
        XCTAssertTrue(app.staticTexts["План"].exists)

        let titleField = app.textFields["tasks.editor.title"]
        titleField.tap()
        titleField.typeText("План проєкту")
        XCTAssertEqual(app.buttons["tasks.editor.save"].label, "Додати завдання")
        app.buttons["tasks.editor.save"].tap()

        let editButton = app.buttons["Редагувати: План проєкту"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))
        let completeButton = app.buttons["Позначити виконаним: План проєкту"]
        XCTAssertTrue(completeButton.exists)
        completeButton.tap()
        XCTAssertTrue(
            app.buttons["Відкрити знову: План проєкту"]
                .waitForExistence(timeout: 2)
        )
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
    func testUsesStatsInUkrainian() throws {
        let app = makeApp(
            showStats: true,
            language: "uk",
            locale: "uk_UA"
        )
        app.launch()

        XCTAssertTrue(app.navigationBars["Статистика"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["stats.history"].label, "Історія фокусу")

        let periodPicker = app.segmentedControls["stats.period"]
        XCTAssertTrue(periodPicker.buttons["День"].exists)
        XCTAssertTrue(periodPicker.buttons["Тиждень"].isSelected)
        XCTAssertTrue(periodPicker.buttons["Місяць"].exists)
        XCTAssertTrue(periodPicker.buttons["Рік"].exists)
        XCTAssertTrue(app.staticTexts["Час фокусу"].exists)
        let focusTimeChart = app.descendants(matching: .any)
            .matching(identifier: "stats.focusTime.chart")
            .firstMatch
        XCTAssertTrue(focusTimeChart.exists)
        XCTAssertEqual(
            focusTimeChart.label,
            "Графік часу фокусу"
        )
        XCTAssertTrue(app.staticTexts["Сесії"].exists)
        XCTAssertTrue(app.staticTexts["Виконано"].exists)

        app.swipeUp()
        XCTAssertTrue(
            app.staticTexts["Найпопулярніші категорії"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.staticTexts["Часу фокусу поки немає"].exists)
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
    func testUsesFocusHistoryInUkrainian() throws {
        let app = makeApp(
            showStats: true,
            language: "uk",
            locale: "uk_UA"
        )
        app.launch()

        let historyButton = app.buttons["stats.history"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 2))
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Історія фокусу"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.descendants(matching: .any)["history.calendar"].exists)
        XCTAssertTrue(app.staticTexts["У фокусі"].exists)
        XCTAssertTrue(app.staticTexts["Сесії"].exists)
        XCTAssertTrue(app.staticTexts["Завдання"].exists)

        app.swipeUp()
        XCTAssertTrue(
            app.staticTexts["Немає сесій фокусу"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            app.staticTexts["Виберіть іншу дату або завершіть сесію фокусу."]
                .exists
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

        app.swipeUp()
        XCTAssertTrue(
            app.descendants(matching: .any)["settings.appearance"]
                .waitForExistence(timeout: 2)
        )
    }

    @MainActor
    func testUsesSettingsInUkrainian() throws {
        let app = makeApp(
            showSettings: true,
            language: "uk",
            locale: "uk_UA"
        )
        app.launch()

        XCTAssertTrue(app.navigationBars["Налаштування"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Таймер"].exists)
        XCTAssertTrue(app.staticTexts["Цикл"].exists)

        let focusDuration = app.descendants(matching: .any)["settings.focusDuration"]
        XCTAssertTrue(focusDuration.exists)
        XCTAssertTrue(focusDuration.label.contains("Фокус"))
        XCTAssertTrue(focusDuration.label.contains("25 хв"))

        let autoStartBreaks = app.switches["settings.autoStartBreaks"]
        XCTAssertEqual(autoStartBreaks.label, "Автозапуск перерв")
        XCTAssertEqual(autoStartBreaks.value as? String, "Вимкнено")

        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Відгук"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.switches["settings.sound"].label, "Звуки")
        XCTAssertEqual(app.switches["settings.haptics"].label, "Вібровідгук")
        XCTAssertEqual(app.switches["settings.notifications"].label, "Сповіщення")
        XCTAssertTrue(app.staticTexts["Вигляд"].exists)

        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Мова"].waitForExistence(timeout: 2))
        let languageButton = app.buttons["settings.language"]
        XCTAssertTrue(languageButton.exists)
        XCTAssertTrue(languageButton.label.contains("Мова застосунку"))
        XCTAssertTrue(languageButton.label.contains("Українська"))
        let languageScreenshot = XCTAttachment(screenshot: app.screenshot())
        languageScreenshot.name = "Ukrainian Language Setting"
        languageScreenshot.lifetime = .keepAlways
        add(languageScreenshot)

        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Дані"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Записані сесії"].exists)
        XCTAssertTrue(app.buttons["Очистити історію фокусу"].exists)
        XCTAssertTrue(app.staticTexts["Про застосунок"].exists)
        XCTAssertTrue(app.staticTexts["Версія"].exists)
    }

    @MainActor
    func testOpensAppLanguageSettings() throws {
        let app = makeApp(showSettings: true)
        let systemSettings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        app.launch()

        app.swipeUp()
        app.swipeUp()
        let languageButton = app.buttons["settings.language"]
        XCTAssertTrue(languageButton.waitForExistence(timeout: 2))
        languageButton.tap()

        XCTAssertTrue(
            systemSettings.wait(for: .runningForeground, timeout: 3),
            "The Language row should open Swish's page in iOS Settings"
        )
    }

    @MainActor
    func testClearsRecordedFocusHistory() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.buttons["Start focus"].waitForExistence(timeout: 3))
        app.buttons["Start focus"].tap()

        let cancelTimer = app.buttons["home.timer.cancel"]
        XCTAssertTrue(cancelTimer.waitForExistence(timeout: 2))
        cancelTimer.tap()

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["settings.screen"]
                .waitForExistence(timeout: 2)
        )

        app.swipeUp()
        app.swipeUp()
        let clearHistory = app.buttons["settings.clearHistory"]
        XCTAssertTrue(clearHistory.waitForExistence(timeout: 2))
        XCTAssertTrue(clearHistory.isEnabled)
        clearHistory.tap()

        let confirmClear = app.buttons["Clear History"]
        XCTAssertTrue(confirmClear.waitForExistence(timeout: 2))
        confirmClear.tap()

        XCTAssertTrue(waitForEnabled(false, of: clearHistory))
        XCTAssertEqual(
            app.staticTexts["settings.historyCount"].label,
            "Recorded sessions, 0"
        )
    }

    private func createTask(named title: String, in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["tasks.add"].waitForExistence(timeout: 2))
        app.buttons["tasks.add"].tap()

        let titleField = app.textFields["tasks.editor.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText(title)
        app.buttons["tasks.editor.save"].tap()

        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 2))
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

    private func waitForEnabled(
        _ isEnabled: Bool,
        of element: XCUIElement,
        timeout: TimeInterval = 2
    ) -> Bool {
        let predicate = NSPredicate(
            format: "enabled == %@",
            NSNumber(value: isEnabled)
        )
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
        showSettings: Bool = false,
        language: String? = nil,
        locale: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-skip-onboarding"
        ]
        if showTasks {
            app.launchArguments.append("--ui-testing-show-tasks")
        }
        if showStats {
            app.launchArguments.append("--ui-testing-show-stats")
        }
        if showSettings {
            app.launchArguments.append("--ui-testing-show-settings")
        }
        if let language {
            app.launchArguments.append(contentsOf: [
                "-AppleLanguages",
                "(\(language))"
            ])
        }
        if let locale {
            app.launchArguments.append(contentsOf: [
                "-AppleLocale",
                locale
            ])
        }
        return app
    }
}
