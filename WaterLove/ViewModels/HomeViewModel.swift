import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    let quickAddAmounts = [100, 200, 300]

    private let recordStore: WaterRecordStore

    var todayTotalAmountML = 0
    var lastDrinkAt: Date?
    var canUndoLastRecord = false
    var dailyTargetAmountML: Int

    init(
        recordStore: WaterRecordStore,
        dailyTargetAmountML: Int = UserSettings.default.dailyTargetAmountML
    ) {
        self.recordStore = recordStore
        self.dailyTargetAmountML = dailyTargetAmountML
        refreshToday()
    }

    var progress: Double {
        guard dailyTargetAmountML > 0 else { return 0 }
        return min(Double(todayTotalAmountML) / Double(dailyTargetAmountML), 1)
    }

    var progressPercentText: String {
        "\(Int((progress * 100).rounded()))%"
    }

    var todayStatusText: String {
        if todayTotalAmountML <= 0 {
            return "先喝第一口水，今天的照顾就从这里开始。"
        }

        if progress >= 1 {
            return "今日目标完成，水分余额满格。"
        }

        return "已经记录 \(todayTotalAmountML) ml，离目标又近了一点。"
    }

    var lastDrinkTimeText: String {
        guard let lastDrinkAt else {
            return "今天还没有记录喝水"
        }

        return "最近一次：\(DateUtils.timeText(from: lastDrinkAt))"
    }

    func addWater(amountML: Int) {
        recordStore.addRecord(amountML: amountML)
        refreshToday()
    }

    func undoLastRecord() {
        recordStore.deleteLastRecordForToday()
        refreshToday()
    }

    func refreshToday() {
        let todayRecords = recordStore.recordsForDate(Date())
        todayTotalAmountML = todayRecords.reduce(0) { $0 + $1.amountML }
        lastDrinkAt = todayRecords.last?.createdAt
        canUndoLastRecord = !todayRecords.isEmpty
    }
}
