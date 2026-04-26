import Foundation
import Observation

@Observable
final class WaterRecordStore {
    private(set) var records: [WaterRecord] = []

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let calendar: Calendar
    private let shouldPersist: Bool

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "waterLove.records.v1",
        calendar: Calendar = .current,
        shouldPersist: Bool = true,
        initialRecords: [WaterRecord] = []
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.calendar = calendar
        self.shouldPersist = shouldPersist

        if initialRecords.isEmpty {
            loadRecords()
        } else {
            records = initialRecords
            sortRecords()
            saveRecords()
        }
    }

    func addRecord(amountML: Int) {
        guard amountML > 0 else { return }

        let record = WaterRecord(amountML: amountML)
        records.append(record)
        sortRecords()
        saveRecords()
    }

    @discardableResult
    func deleteLastRecordForToday() -> WaterRecord? {
        guard let lastRecord = recordsForDate(Date()).last else {
            return nil
        }

        records.removeAll { $0.id == lastRecord.id }
        saveRecords()
        return lastRecord
    }

    func recordsForDate(_ date: Date) -> [WaterRecord] {
        records
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func totalAmountForDate(_ date: Date) -> Int {
        recordsForDate(date).reduce(0) { $0 + $1.amountML }
    }

    func summariesForRecentDays(
        _ dayCount: Int,
        targetAmountML: Int = UserSettings.default.dailyTargetAmountML
    ) -> [DailyWaterSummary] {
        guard dayCount > 0 else { return [] }

        let today = calendar.startOfDay(for: Date())
        let summaries = (0..<dayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }

            return DailyWaterSummary(
                date: date,
                totalAmountML: totalAmountForDate(date),
                targetAmountML: targetAmountML
            )
        }

        return Array(summaries.reversed())
    }

    func clearAllRecords() {
        records.removeAll()
        saveRecords()
    }

    private func loadRecords() {
        guard
            shouldPersist,
            let data = userDefaults.data(forKey: storageKey)
        else {
            records = []
            return
        }

        do {
            records = try JSONDecoder().decode([WaterRecord].self, from: data)
            sortRecords()
        } catch {
            records = []
        }
    }

    private func saveRecords() {
        guard shouldPersist else { return }

        do {
            let data = try JSONEncoder().encode(records)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save water records: \(error.localizedDescription)")
        }
    }

    private func sortRecords() {
        records.sort { $0.createdAt < $1.createdAt }
    }
}

extension WaterRecordStore {
    static var preview: WaterRecordStore {
        WaterRecordStore(
            shouldPersist: false,
            initialRecords: [
                WaterRecord(amountML: 200, createdAt: Date().addingTimeInterval(-7200)),
                WaterRecord(amountML: 300, createdAt: Date().addingTimeInterval(-3600)),
                WaterRecord(amountML: 200, createdAt: Date().addingTimeInterval(-900))
            ]
        )
    }
}
