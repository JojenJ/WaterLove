import SwiftUI

struct DailyRecordCard: View {
    let summary: DailyWaterSummary

    private var progressPercentText: String {
        "\(Int((summary.progress * 100).rounded()))%"
    }

    private var progressColor: Color {
        summary.isGoalReached ? AppColors.softPink : AppColors.waterBlue
    }

    var body: some View {
        HStack(spacing: 14) {
            dateBlock
            detailBlock
            statusBadge
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
    }

    private var dateBlock: some View {
        VStack(spacing: 5) {
            Text(DateUtils.shortDateText(from: summary.date))
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.ink)

            Text(DateUtils.weekdayText(from: summary.date))
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.secondaryInk)
        }
        .frame(width: 58)
    }

    private var detailBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(summary.totalAmountML) ml")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.ink)

                Text("/ \(summary.targetAmountML) ml")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryInk)

                Spacer(minLength: 6)

                Text(progressPercentText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(progressColor)
            }

            ProgressView(value: summary.progress)
                .tint(progressColor)
                .accessibilityHidden(true)
        }
    }

    private var statusBadge: some View {
        Image(systemName: summary.isGoalReached ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(summary.isGoalReached ? AppColors.softPink : AppColors.secondaryInk.opacity(0.42))
            .accessibilityLabel(summary.isGoalReached ? "已达标" : "未达标")
    }
}

#Preview {
    VStack {
        DailyRecordCard(
            summary: DailyWaterSummary(
                date: Date(),
                totalAmountML: 1900,
                targetAmountML: 1800
            )
        )

        DailyRecordCard(
            summary: DailyWaterSummary(
                date: Date().addingTimeInterval(-86400),
                totalAmountML: 860,
                targetAmountML: 1800
            )
        )
    }
    .padding()
    .background(AppColors.backgroundGradient)
}
