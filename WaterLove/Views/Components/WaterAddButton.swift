import SwiftUI

struct WaterAddButton: View {
    let amountML: Int
    let isRecommended: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.28))
                        .frame(width: 34, height: 34)

                    Image(systemName: "drop.fill")
                        .font(.system(size: 16, weight: .bold))
                }

                Text("+\(amountML)")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()

                Text("ml")
                    .font(.caption.weight(.semibold))
                    .opacity(0.82)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
        }
        .buttonStyle(WaterAddButtonStyle(isRecommended: isRecommended))
        .accessibilityLabel("记录喝水 \(amountML) 毫升")
    }
}

private struct WaterAddButtonStyle: ButtonStyle {
    let isRecommended: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isRecommended ? .white : AppColors.ink)
            .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(isRecommended ? 0.42 : 0.68), lineWidth: 1)
            }
            .shadow(
                color: (isRecommended ? AppColors.waterBlue : .black).opacity(configuration.isPressed ? 0.08 : 0.12),
                radius: configuration.isPressed ? 8 : 14,
                y: configuration.isPressed ? 4 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }

    private var backgroundStyle: AnyShapeStyle {
        if isRecommended {
            AnyShapeStyle(LinearGradient(
                colors: [AppColors.waterBlue, AppColors.lilac],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        } else {
            AnyShapeStyle(AppColors.cardBackground)
        }
    }
}

#Preview {
    HStack {
        WaterAddButton(amountML: 100, isRecommended: false) {}
        WaterAddButton(amountML: 200, isRecommended: true) {}
        WaterAddButton(amountML: 300, isRecommended: false) {}
    }
    .padding()
    .background(AppColors.backgroundGradient)
}
