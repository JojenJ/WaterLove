import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(recordStore: WaterRecordStore) {
        _viewModel = State(initialValue: HomeViewModel(recordStore: recordStore))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("今天也要好好喝水呀，宝宝")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.ink)

                    Text(viewModel.todayStatusText)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryInk)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)

                todayCard

                quickAddSection

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
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 28)
        }
        .navigationTitle("WaterLove")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refreshToday()
        }
    }

    private var todayCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.waterBlue)

            VStack(spacing: 6) {
                Text("\(viewModel.todayTotalAmountML) ml")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.ink)

                Text("今日目标 \(viewModel.dailyTargetAmountML) ml")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
            }

            ProgressView(value: viewModel.progress)
                .tint(AppColors.waterBlue)
                .accessibilityLabel("今日喝水进度")
                .accessibilityValue(viewModel.progressPercentText)

            Text(viewModel.lastDrinkTimeText)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppColors.secondaryInk)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
        .padding(.horizontal, 20)
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速记录")
                .font(.headline)
                .foregroundStyle(AppColors.ink)
                .padding(.horizontal, 4)

            HStack(spacing: 10) {
                ForEach(viewModel.quickAddAmounts, id: \.self) { amount in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            viewModel.addWater(amountML: amount)
                        }
                    } label: {
                        Text("+\(amount)ml")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.waterBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        HomeView(recordStore: WaterRecordStore.preview)
    }
}
