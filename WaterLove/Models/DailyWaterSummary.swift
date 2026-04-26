import Foundation

struct DailyWaterSummary: Identifiable, Codable, Hashable {
    let date: Date
    let totalAmountML: Int
    let targetAmountML: Int

    var id: Date {
        Calendar.current.startOfDay(for: date)
    }

    var progress: Double {
        guard targetAmountML > 0 else { return 0 }
        return min(Double(totalAmountML) / Double(targetAmountML), 1)
    }

    var isGoalReached: Bool {
        totalAmountML >= targetAmountML
    }
}
