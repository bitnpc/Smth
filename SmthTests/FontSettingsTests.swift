import XCTest
@testable import Smth

final class FontSettingsTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "FontSettingsTests")!
        defaults.removePersistentDomain(forName: "FontSettingsTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "FontSettingsTests")
        defaults = nil
        super.tearDown()
    }

    func testDefaultIsStandard() {
        let settings = FontSettings(storage: defaults)
        XCTAssertEqual(settings.selectedOption, .standard)
    }

    func testPersistence() {
        var settings = FontSettings(storage: defaults)
        settings.selectedOption = .large

        settings = FontSettings(storage: defaults)
        XCTAssertEqual(settings.selectedOption, .large)
    }
}


