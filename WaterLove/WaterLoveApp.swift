import SwiftUI

@main
struct WaterLoveApp: App {
    @State private var recordStore = WaterRecordStore()

    var body: some Scene {
        WindowGroup {
            MainTabView(recordStore: recordStore)
        }
    }
}
