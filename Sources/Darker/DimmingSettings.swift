import Foundation
import Combine

@MainActor final class DimmingSettings: ObservableObject {
    static let maximum = 90.0
    @Published private(set) var amount: Double
    var onChange: (() -> Void)?
    private let defaults: UserDefaults

    var opacity: Double { amount / 100 }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        amount = Self.clamped(defaults.double(forKey: "dimmingAmount"))
    }

    func setAmount(_ value: Double) {
        amount = Self.clamped(value)
        save()
    }

    func clear() {
        amount = 0
        save()
    }

    private func save() {
        defaults.set(amount, forKey: "dimmingAmount")
        onChange?()
    }

    private static func clamped(_ value: Double) -> Double {
        value.isFinite ? min(max(value, 0), maximum) : 0
    }
}
