import SwiftUI

@main
struct WaterLoveApp: App {
    @State private var recordStore = WaterRecordStore()
    @State private var settingsStore = UserSettingsStore()

    var body: some Scene {
        WindowGroup {
            MainTabView(recordStore: recordStore, settingsStore: settingsStore)
        }
    }
}
