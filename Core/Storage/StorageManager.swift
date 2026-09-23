import Foundation

final class StorageManager {

    static let shared = StorageManager()

    private let defaults: UserDefaults

    private init(
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
    }

    func bool(
        forKey key: String,
        defaultValue: Bool = false
    ) -> Bool {
        if defaults.object(forKey: key) == nil {
            return defaultValue
        }

        return defaults.bool(forKey: key)
    }

    func set(
        _ value: Bool,
        forKey key: String
    ) {
        defaults.set(value, forKey: key)
    }

    func integer(
        forKey key: String,
        defaultValue: Int = 0
    ) -> Int {
        if defaults.object(forKey: key) == nil {
            return defaultValue
        }

        return defaults.integer(forKey: key)
    }

    func set(
        _ value: Int,
        forKey key: String
    ) {
        defaults.set(value, forKey: key)
    }
}
