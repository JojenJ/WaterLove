import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ContentUnavailableView {
                Label("最近 7 天记录", systemImage: "calendar.badge.clock")
            } description: {
                Text("阶段 4 会展示每日喝水量、进度和达标状态。")
            }
        }
        .navigationTitle("喝水记录")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
