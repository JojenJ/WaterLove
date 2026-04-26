import Foundation

final class UserSettingsStore {
    private(set) var settings: UserSettings

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let shouldPersist: Bool

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "waterLove.userSettings.v1",
        shouldPersist: Bool = true,
        initialSettings: UserSettings? = nil
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.shouldPersist = shouldPersist

        if let initialSettings {
            settings = initialSettings
            saveSettings()
        } else {
            settings = Self.loadSettings(
                from: userDefaults,
                key: storageKey,
                shouldPersist: shouldPersist
            )
        }
    }

    func update(_ newSettings: UserSettings) {
        settings = newSettings
        saveSettings()
    }

    func resetToDefault() {
        settings = .default
        saveSettings()
    }

    private func saveSettings() {
        guard shouldPersist else { return }

        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save user settings: \(error.localizedDescription)")
        }
    }

    private static func loadSettings(
        from userDefaults: UserDefaults,
        key: String,
        shouldPersist: Bool
    ) -> UserSettings {
        guard
            shouldPersist,
            let data = userDefaults.data(forKey: key)
        else {
            return .default
        }

        do {
            return try JSONDecoder().decode(UserSettings.self, from: data)
        } catch {
            return .default
        }
    }
}

extension UserSettingsStore {
    static var preview: UserSettingsStore {
        UserSettingsStore(shouldPersist: false)
    }
}
