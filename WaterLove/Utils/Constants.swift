import SwiftUI

enum AppColors {
    static let waterBlue = Color(red: 0.23, green: 0.61, blue: 0.92)
    static let softPink = Color(red: 1.00, green: 0.72, blue: 0.79)
    static let cream = Color(red: 1.00, green: 0.97, blue: 0.92)
    static let lilac = Color(red: 0.78, green: 0.72, blue: 0.96)
    static let ink = Color(red: 0.20, green: 0.22, blue: 0.30)
    static let secondaryInk = Color(red: 0.45, green: 0.47, blue: 0.56)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                cream,
                Color(red: 0.91, green: 0.97, blue: 1.00),
                Color(red: 0.98, green: 0.91, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
