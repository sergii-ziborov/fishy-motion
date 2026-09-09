import XCTest

final class FishyMotionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndSolveFirstLevel() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["home-title"].waitForExistence(timeout: 5))
        saveShot("home")
        XCTAssertTrue(app.buttons["play-button"].exists)
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.staticTexts["prompt-title"].waitForExistence(timeout: 5))
        saveShot("play")

        let fish = app.buttons["fish-0"].firstMatch
        XCTAssertTrue(fish.waitForExistence(timeout: 6), app.debugDescription)
        fish.tap()
        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 6))
        saveShot("result")
        XCTAssertTrue(app.buttons["next-level-button"].exists)
    }

    func testWorldsCollectionAndSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["worlds-button"].tap()
        XCTAssertTrue(app.staticTexts["Worlds"].waitForExistence(timeout: 5))
        saveShot("worlds")
        app.buttons["back-button"].tap()
        app.buttons["collection-button"].tap()
        XCTAssertTrue(app.buttons["theme-classic"].waitForExistence(timeout: 5))
        saveShot("collection")
        app.buttons["back-button"].tap()
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        saveShot("settings")
        app.buttons["back-button"].tap()
        app.buttons["daily-button"].tap()
        XCTAssertTrue(app.staticTexts["Daily Puzzle"].waitForExistence(timeout: 5))
        saveShot("daily")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
