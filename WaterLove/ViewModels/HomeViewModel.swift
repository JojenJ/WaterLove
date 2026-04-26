import Foundation
import Observation

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

    var remainingAmountML: Int {
        max(dailyTargetAmountML - todayTotalAmountML, 0)
    }

    var remainingAmountText: String {
        remainingAmountML > 0 ? "还差 \(remainingAmountML) ml" : "已达标"
    }

    var progressLevelTitle: String {
        if todayTotalAmountML <= 0 {
            return "等待第一口水"
        }

        if progress < 0.35 {
            return "水分刚起步"
        }

        if progress < 0.75 {
            return "状态在升温"
        }

        if progress < 1 {
            return "快完成啦"
        }

        return "今日已达标"
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

    var encouragementText: String {
        if todayTotalAmountML <= 0 {
            return "宝宝，先喝一口水吧。我先温柔提醒一次，后面可能会更认真一点。"
        }

        if progress < 0.35 {
            return "开局不错，再补一点水分，今天的小花就不会皱巴巴。"
        }

        if progress < 0.75 {
            return "节奏很好，再来几口，水分余额正在乖乖回升。"
        }

        if progress < 1 {
            return "就差 \(remainingAmountML) ml 了，喝完这段进度条会很有成就感。"
        }

        return "今日喝水目标完成。很棒，先允许你得意三秒。"
    }

    var lastDrinkTimeText: String {
        guard let lastDrinkAt else {
            return "今天还没有记录喝水"
        }

        return "最近一次：\(DateUtils.timeText(from: lastDrinkAt))"
    }

    var lastDrinkShortText: String {
        guard let lastDrinkAt else {
            return "未记录"
        }

        return DateUtils.timeText(from: lastDrinkAt)
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
