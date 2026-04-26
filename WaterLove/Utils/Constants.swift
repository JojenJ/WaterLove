import SwiftUI
import UIKit

enum AppColors {
    static let waterBlue = Color(red: 0.23, green: 0.61, blue: 0.92)
    static let softPink = Color(red: 1.00, green: 0.72, blue: 0.79)
    static let cream = Color(red: 1.00, green: 0.97, blue: 0.92)
    static let lilac = Color(red: 0.78, green: 0.72, blue: 0.96)
    static let ink = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.94, blue: 0.98, alpha: 1)
            : UIColor(red: 0.20, green: 0.22, blue: 0.30, alpha: 1)
    })
    static let secondaryInk = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.72, green: 0.74, blue: 0.82, alpha: 1)
            : UIColor(red: 0.45, green: 0.47, blue: 0.56, alpha: 1)
    })
    static let cardBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.15, blue: 0.20, alpha: 0.88)
            : UIColor(white: 1, alpha: 0.74)
    })
    static let cardStroke = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.10)
            : UIColor(white: 1, alpha: 0.70)
    })

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private static var backgroundColors: [Color] {
        [
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1)
                    : UIColor(red: 1.00, green: 0.97, blue: 0.92, alpha: 1)
            }),
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.09, green: 0.15, blue: 0.20, alpha: 1)
                    : UIColor(red: 0.91, green: 0.97, blue: 1.00, alpha: 1)
            }),
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.16, green: 0.11, blue: 0.18, alpha: 1)
                    : UIColor(red: 0.98, green: 0.91, blue: 0.96, alpha: 1)
            })
        ]
    }
}

private struct AppCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.cardStroke, lineWidth: 1)
            }
            .shadow(color: .black.opacity(shadowOpacity), radius: 16, y: 8)
    }
}

extension View {
    func appCard(cornerRadius: CGFloat = 24, shadowOpacity: Double = 0.06) -> some View {
        modifier(AppCardModifier(cornerRadius: cornerRadius, shadowOpacity: shadowOpacity))
    }
}
