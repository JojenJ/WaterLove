import Foundation
import Observation

@Observable
final class HistoryViewModel {
    private let recordStore: WaterRecordStore
    private let settingsStore: UserSettingsStore
    private let dayCount: Int

    var summaries: [DailyWaterSummary] = []

    init(
        recordStore: WaterRecordStore,
        settingsStore: UserSettingsStore,
        dayCount: Int = 7
    ) {
        self.recordStore = recordStore
        self.settingsStore = settingsStore
        self.dayCount = dayCount
        refresh()
    }

    var totalAmountText: String {
        "\(summaries.reduce(0) { $0 + $1.totalAmountML }) ml"
    }

    var averageAmountText: String {
        guard !summaries.isEmpty else { return "0 ml" }
        let average = summaries.reduce(0) { $0 + $1.totalAmountML } / summaries.count
        return "\(average) ml"
    }

    var reachedDaysText: String {
        "\(summaries.filter(\.isGoalReached).count)/\(summaries.count) 天"
    }

    var hasAnyRecords: Bool {
        summaries.contains { $0.totalAmountML > 0 }
    }

    var weekSummaryText: String {
        if !hasAnyRecords {
            return "还没有历史记录。今天先喝第一口水，明天这里就会开始亮起来。"
        }

        let reachedDays = summaries.filter(\.isGoalReached).count
        if reachedDays >= 5 {
            return "这周水分状态很稳，继续保持这个节奏。"
        }

        if reachedDays > 0 {
            return "已经有达标日了，再多几个小勾勾会更漂亮。"
        }

        return "最近有记录，但还没有达标日。下一次提醒会更有方向感。"
    }

    func refresh() {
        let targetAmountML = settingsStore.settings.dailyTargetAmountML
        summaries = recordStore.summariesForRecentDays(dayCount, targetAmountML: targetAmountML)
    }
}
