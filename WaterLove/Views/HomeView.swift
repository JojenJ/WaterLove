import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("今天也要好好喝水呀，宝宝")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.ink)

                    Text("WaterLove 已经准备好陪你记录每一口水。")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryInk)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.72))
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "drop.circle.fill")
                                .font(.system(size: 58))
                                .foregroundStyle(AppColors.waterBlue)

                            Text("阶段 2 会在这里接入喝水记录")
                                .font(.headline)
                                .foregroundStyle(AppColors.ink)

                            Text("今日总量、目标进度和快捷加水按钮会从 ViewModel 驱动。")
                                .font(.footnote)
                                .foregroundStyle(AppColors.secondaryInk)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 28)
        }
        .navigationTitle("WaterLove")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
