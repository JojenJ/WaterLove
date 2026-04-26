import Foundation
import UserNotifications

enum NotificationServiceError: LocalizedError {
    case notAuthorized
    case noReminderSlots

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "通知权限还没有开启"
        case .noReminderSlots:
            return "提醒时间段太短，无法生成提醒"
        }
    }
}

final class NotificationService {
    private let notificationCenter: UNUserNotificationCenter
    private let messageProvider: NotificationMessageProvider
    private let recordStore: WaterRecordStore
    private let settingsStore: UserSettingsStore

    private let reminderIdentifierPrefix = "waterLove.reminder."
    private let testIdentifierPrefix = "waterLove.test."
    private let maxScheduledReminders = 60

    init(
        notificationCenter: UNUserNotificationCenter = .current(),
        messageProvider: NotificationMessageProvider = NotificationMessageProvider(),
        recordStore: WaterRecordStore,
        settingsStore: UserSettingsStore
    ) {
        self.notificationCenter = notificationCenter
        self.messageProvider = messageProvider
        self.recordStore = recordStore
        self.settingsStore = settingsStore
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    @discardableResult
    func scheduleDailyWaterReminders(settings: UserSettings) async throws -> Int {
        guard settings.isReminderEnabled else {
            await cancelAllWaterReminders()
            return 0
        }

        guard await hasNotificationAuthorization() else {
            throw NotificationServiceError.notAuthorized
        }

        let slots = reminderSlots(for: settings)
        guard !slots.isEmpty else {
            throw NotificationServiceError.noReminderSlots
        }

        await cancelAllWaterReminders()

        let progress = progressSnapshot(for: settings)
        let limitedSlots = Array(slots.prefix(maxScheduledReminders))

        for (index, slot) in limitedSlots.enumerated() {
            let scenario = scenario(
                forSlotMinutes: slot.minutes,
                index: index,
                settings: settings,
                progress: progress
            )
            let message = messageProvider.randomNotification(
                nickname: settings.nickname,
                tone: settings.notificationTone,
                scenario: scenario,
                progress: progress
            )

            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default
            content.threadIdentifier = "waterLove.dailyReminder"
            content.userInfo = [
                "source": "WaterLove",
                "kind": "dailyReminder",
                "scenario": scenario.rawValue
            ]

            var dateComponents = DateComponents()
            dateComponents.hour = slot.hour
            dateComponents.minute = slot.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifierPrefix)\(slot.hour)-\(slot.minute)",
                content: content,
                trigger: trigger
            )

            try await add(request)
        }

        return limitedSlots.count
    }

    func cancelAllWaterReminders() async {
        let identifiers = await pendingRequestIdentifiers(withPrefix: reminderIdentifierPrefix)
        guard !identifiers.isEmpty else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleTestNotification(settings: UserSettings? = nil) async throws {
        guard await hasNotificationAuthorization() else {
            throw NotificationServiceError.notAuthorized
        }

        let currentSettings = settings ?? settingsStore.settings
        let progress = progressSnapshot(for: currentSettings)
        let scenario = scenario(
            forSlotMinutes: DateUtils.minutesSinceStartOfDay(for: Date()),
            index: 0,
            settings: currentSettings,
            progress: progress
        )
        let message = messageProvider.randomNotification(
            nickname: currentSettings.nickname,
            tone: currentSettings.notificationTone,
            scenario: scenario,
            progress: progress
        )

        let content = UNMutableNotificationContent()
        content.title = "测试通知"
        content.body = message.body
        content.sound = .default
        content.threadIdentifier = "waterLove.testReminder"
        content.userInfo = [
            "source": "WaterLove",
            "kind": "testReminder",
            "scenario": scenario.rawValue
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(testIdentifierPrefix)\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await add(request)
    }

    @discardableResult
    func rescheduleNotificationsIfNeeded() async throws -> Int {
        let settings = settingsStore.settings
        guard settings.isReminderEnabled else {
            await cancelAllWaterReminders()
            return 0
        }

        return try await scheduleDailyWaterReminders(settings: settings)
    }

    private func hasNotificationAuthorization() async -> Bool {
        let settings = await notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            notificationCenter.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func pendingRequestIdentifiers(withPrefix prefix: String) async -> [String] {
        await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests { requests in
                let identifiers = requests
                    .map(\.identifier)
                    .filter { $0.hasPrefix(prefix) }
                continuation.resume(returning: identifiers)
            }
        }
    }

    private func reminderSlots(for settings: UserSettings) -> [ReminderSlot] {
        let startMinutes = settings.reminderStartHour * 60 + settings.reminderStartMinute
        let endMinutes = settings.reminderEndHour * 60 + settings.reminderEndMinute
        let interval = max(settings.reminderIntervalMinutes, 1)
        guard startMinutes < endMinutes else { return [] }

        var slots: [ReminderSlot] = []
        var current = startMinutes
        while current <= endMinutes {
            slots.append(ReminderSlot(minutes: current))
            current += interval
        }

        return slots
    }

    private func progressSnapshot(for settings: UserSettings) -> Double {
        guard settings.dailyTargetAmountML > 0 else { return 0 }
        let total = recordStore.totalAmountForDate(Date())
        return min(Double(total) / Double(settings.dailyTargetAmountML), 1)
    }

    private func scenario(
        forSlotMinutes slotMinutes: Int,
        index: Int,
        settings: UserSettings,
        progress: Double
    ) -> NotificationScenario {
        if progress >= 1 {
            return .goalCompleted
        }

        if progress >= 0.82 {
            return .goalAlmostDone
        }

        if slotMinutes >= 20 * 60 {
            return .eveningWrapUp
        }

        let startMinutes = settings.reminderStartHour * 60 + settings.reminderStartMinute
        if progress < 0.12 && slotMinutes >= startMinutes + settings.reminderIntervalMinutes * 2 {
            return .missedCheck
        }

        if index > 0 && index % 6 == 0 {
            return .personal
        }

        if progress < 0.35 {
            return .lowProgress
        }

        if slotMinutes < 12 * 60 {
            return .morning
        }

        if slotMinutes < 18 * 60 {
            return .afternoon
        }

        return .evening
    }
}

private struct ReminderSlot {
    let minutes: Int

    var hour: Int {
        minutes / 60
    }

    var minute: Int {
        minutes % 60
    }
}
