import XCTest
@testable import Darker

final class DimmingSettingsTests: XCTestCase {
    @MainActor func testFirstLaunchDoesNotDim() {
        withDefaults { defaults in
            let settings = DimmingSettings(defaults: defaults)
            XCTAssertEqual(settings.opacity, 0)
        }
    }

    @MainActor func testDimmingSurvivesRelaunch() {
        withDefaults { defaults in
            let settings = DimmingSettings(defaults: defaults)
            settings.setAmount(65)
            let restored = DimmingSettings(defaults: defaults)
            XCTAssertEqual(restored.amount, 65)
            XCTAssertEqual(restored.opacity, 0.65)
        }
    }

    @MainActor func testSliderCanTurnOffAndClearPersists() {
        withDefaults { defaults in
            let settings = DimmingSettings(defaults: defaults)
            settings.setAmount(70)
            settings.setAmount(0)
            XCTAssertEqual(settings.opacity, 0)
            XCTAssertEqual(DimmingSettings(defaults: defaults).opacity, 0)
            settings.setAmount(30)
            settings.clear()
            XCTAssertEqual(DimmingSettings(defaults: defaults).opacity, 0)
        }
    }

    @MainActor func testSavedValuesCannotCompletelyBlackOutDisplay() {
        withDefaults { defaults in
            defaults.set(100, forKey: "dimmingAmount")
            let settings = DimmingSettings(defaults: defaults)
            XCTAssertEqual(settings.opacity, 0.9)
            settings.setAmount(.infinity)
            XCTAssertEqual(settings.opacity, 0)
            settings.setAmount(-20)
            XCTAssertEqual(settings.opacity, 0)
        }
    }

    @MainActor private func withDefaults(_ test: (UserDefaults) -> Void) {
        let name = "DarkerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        test(defaults)
    }
}
