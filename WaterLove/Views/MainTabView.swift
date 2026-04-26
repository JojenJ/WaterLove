import SwiftUI

struct MainTabView: View {
    let recordStore: WaterRecordStore

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(recordStore: recordStore)
            }
            .tabItem {
                Label("首页", systemImage: "drop.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("记录", systemImage: "calendar")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
        }
        .tint(AppColors.waterBlue)
    }
}

#Preview {
    MainTabView(recordStore: WaterRecordStore.preview)
}
