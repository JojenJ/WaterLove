import SwiftUI

struct MainTabView: View {
    let recordStore: WaterRecordStore
    let settingsStore: UserSettingsStore

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(recordStore: recordStore, settingsStore: settingsStore)
            }
            .tabItem {
                Label("首页", systemImage: "drop.fill")
            }

            NavigationStack {
                HistoryView(recordStore: recordStore, settingsStore: settingsStore)
            }
            .tabItem {
                Label("记录", systemImage: "calendar")
            }

            NavigationStack {
                SettingsView(settingsStore: settingsStore)
            }
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
        }
        .tint(AppColors.waterBlue)
    }
}

#Preview {
    MainTabView(recordStore: WaterRecordStore.preview, settingsStore: UserSettingsStore.preview)
}
