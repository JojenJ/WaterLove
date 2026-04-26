import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var isProgressPulsing = false

    init(recordStore: WaterRecordStore, settingsStore: UserSettingsStore) {
        _viewModel = State(initialValue: HomeViewModel(recordStore: recordStore, settingsStore: settingsStore))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    todayCard
                    reminderCard
                    quickAddSection
                    undoButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 28)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("WaterLove")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.increase, trigger: viewModel.todayTotalAmountML)
        .onAppear {
            viewModel.refreshToday()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("今天也要好好喝水呀，\(viewModel.nickname)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.ink)

                Text(viewModel.todayStatusText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.softPink)
                .accessibilityHidden(true)
        }
    }

    private var todayCard: some View {
        VStack(spacing: 18) {
            ProgressRingView(
                progress: viewModel.progress,
                amountText: "\(viewModel.todayTotalAmountML) ml",
                targetText: "目标 \(viewModel.dailyTargetAmountML) ml",
                percentText: viewModel.progressPercentText,
                statusText: viewModel.progressLevelTitle
            )
            .scaleEffect(isProgressPulsing ? 1.035 : 1)

            metricRow
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 20, y: 12)
    }

    private var metricRow: some View {
        HStack(spacing: 0) {
            metricItem(title: "还差", value: viewModel.remainingAmountText)

            Divider()
                .frame(height: 38)
                .padding(.horizontal, 12)

            metricItem(title: "进度", value: viewModel.progressPercentText)

            Divider()
                .frame(height: 38)
                .padding(.horizontal, 12)

            metricItem(title: "最近", value: viewModel.lastDrinkShortText)
        }
    }

    private func metricItem(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.secondaryInk)

            Text(value)
                .font(.footnote.weight(.bold))
                .foregroundStyle(AppColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var reminderCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.softPink.opacity(0.22))
                    .frame(width: 44, height: 44)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(AppColors.softPink)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("今日陪伴提醒")
                    .font(.headline)
                    .foregroundStyle(AppColors.ink)

                Text(viewModel.encouragementText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速记录")
                .font(.headline)
                .foregroundStyle(AppColors.ink)
                .padding(.horizontal, 2)

            HStack(spacing: 10) {
                ForEach(viewModel.quickAddAmounts, id: \.self) { amount in
                    WaterAddButton(
                        amountML: amount,
                        isRecommended: amount == viewModel.defaultDrinkAmountML
                    ) {
                        addWater(amount)
                    }
                }
            }
        }
    }

    private var undoButton: some View {
        Button {
            withAnimation(.snappy) {
                viewModel.undoLastRecord()
            }
        } label: {
            Label("撤销最近一次", systemImage: "arrow.uturn.backward")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(AppColors.softPink)
        .disabled(!viewModel.canUndoLastRecord)
        .opacity(viewModel.canUndoLastRecord ? 1 : 0.55)
    }

    private func addWater(_ amount: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
            viewModel.addWater(amountML: amount)
            isProgressPulsing = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                isProgressPulsing = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(recordStore: WaterRecordStore.preview, settingsStore: UserSettingsStore.preview)
    }
}
