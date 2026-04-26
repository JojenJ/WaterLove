import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel

    init(recordStore: WaterRecordStore, settingsStore: UserSettingsStore) {
        _viewModel = State(initialValue: HistoryViewModel(recordStore: recordStore, settingsStore: settingsStore))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    weekStats
                    recentDays
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("喝水记录")
        .onAppear {
            viewModel.refresh()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("最近 7 天打卡")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.ink)

                Text(viewModel.weekSummaryText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.waterBlue)
                .accessibilityHidden(true)
        }
    }

    private var weekStats: some View {
        HStack(spacing: 10) {
            statCard(title: "总喝水", value: viewModel.totalAmountText, icon: "drop.fill", color: AppColors.waterBlue)
            statCard(title: "日均", value: viewModel.averageAmountText, icon: "chart.bar.fill", color: AppColors.lilac)
            statCard(title: "达标", value: viewModel.reachedDaysText, icon: "checkmark.seal.fill", color: AppColors.softPink)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
    }

    private var recentDays: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日完成情况")
                .font(.headline)
                .foregroundStyle(AppColors.ink)
                .padding(.horizontal, 2)

            VStack(spacing: 10) {
                ForEach(viewModel.summaries) { summary in
                    DailyRecordCard(summary: summary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(recordStore: WaterRecordStore.preview, settingsStore: UserSettingsStore.preview)
    }
}
