import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ContentUnavailableView {
                Label("个性化设置", systemImage: "slider.horizontal.3")
            } description: {
                Text("阶段 5 会加入昵称、目标水量、提醒时间和通知语气。")
            }
        }
        .navigationTitle("设置")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
