import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let amountText: String
    let targetText: String
    let percentText: String
    let statusText: String

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.waterBlue.opacity(0.12), lineWidth: 22)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            AppColors.waterBlue,
                            AppColors.lilac,
                            AppColors.softPink,
                            AppColors.waterBlue
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 22, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppColors.waterBlue)

                Text(amountText)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.ink)
                    .contentTransition(.numericText())

                Text(targetText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.secondaryInk)

                Text(percentText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.waterBlue, in: Capsule())

                Text(statusText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryInk)
            }
        }
        .frame(width: 236, height: 236)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("今日喝水进度")
        .accessibilityValue("\(amountText)，\(percentText)，\(statusText)")
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: clampedProgress)
    }
}

#Preview {
    ProgressRingView(
        progress: 0.58,
        amountText: "1040 ml",
        targetText: "目标 1800 ml",
        percentText: "58%",
        statusText: "状态在升温"
    )
    .padding()
    .background(AppColors.backgroundGradient)
}
