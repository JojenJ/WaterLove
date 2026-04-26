import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    let reminderIntervalOptions = [30, 60, 120]

    private let settingsStore: UserSettingsStore
    private let notificationService: NotificationService

    var nickname: String
    var dailyTargetAmountML: Int
    var defaultDrinkAmountML: Int
    var reminderStartDate: Date
    var reminderEndDate: Date
    var reminderIntervalMinutes: Int
    var isReminderEnabled: Bool
    var notificationTone: NotificationTone
    var statusMessage = "设置已保存"
    var isNotificationBusy = false

    init(settingsStore: UserSettingsStore, notificationService: NotificationService) {
        self.settingsStore = settingsStore
        self.notificationService = notificationService

        let settings = settingsStore.settings
        nickname = settings.nickname
        dailyTargetAmountML = settings.dailyTargetAmountML
        defaultDrinkAmountML = settings.defaultDrinkAmountML
        reminderStartDate = DateUtils.dateForTime(
            hour: settings.reminderStartHour,
            minute: settings.reminderStartMinute
        )
        reminderEndDate = DateUtils.dateForTime(
            hour: settings.reminderEndHour,
            minute: settings.reminderEndMinute
        )
        reminderIntervalMinutes = settings.reminderIntervalMinutes
        isReminderEnabled = settings.isReminderEnabled
        notificationTone = settings.notificationTone
    }

    var targetAmountText: String {
        "\(dailyTargetAmountML) ml"
    }

    var defaultDrinkAmountText: String {
        "\(defaultDrinkAmountML) ml"
    }

    var reminderIntervalText: String {
        if reminderIntervalMinutes < 60 {
            return "\(reminderIntervalMinutes) 分钟"
        }

        return "\(reminderIntervalMinutes / 60) 小时"
    }

    var reminderStatusText: String {
        isReminderEnabled ? "提醒已开启" : "提醒已关闭"
    }

    func updateNickname(_ newValue: String) {
        nickname = newValue
        save(status: "昵称已保存")
    }

    func updateDailyTargetAmount(_ newValue: Int) {
        dailyTargetAmountML = min(max(newValue, 800), 3000)
        save(status: "目标水量已保存")
    }

    func updateDefaultDrinkAmount(_ newValue: Int) {
        defaultDrinkAmountML = min(max(newValue, 50), 600)
        save(status: "默认水量已保存")
    }

    func updateReminderStartDate(_ newValue: Date) {
        reminderStartDate = newValue
        ensureValidReminderRange(preferMovingEndDate: true)
        save(status: "提醒已更新")
    }

    func updateReminderEndDate(_ newValue: Date) {
        reminderEndDate = newValue
        ensureValidReminderRange(preferMovingEndDate: false)
        save(status: "提醒已更新")
    }

    func updateReminderIntervalMinutes(_ newValue: Int) {
        reminderIntervalMinutes = newValue
        save(status: "提醒已更新")
    }

    func updateReminderEnabled(_ newValue: Bool) {
        isReminderEnabled = newValue
        save(status: newValue ? "正在请求通知权限" : "提醒已关闭", shouldReschedule: false)

        if newValue {
            requestAuthorizationAndSchedule()
        } else {
            cancelReminders()
        }
    }

    func updateNotificationTone(_ newValue: NotificationTone) {
        notificationTone = newValue
        save(status: "通知语气已保存")
    }

    func requestAuthorizationAndSchedule() {
        isNotificationBusy = true
        statusMessage = "正在请求通知权限"

        Task {
            let granted = await notificationService.requestAuthorization()
            guard granted else {
                isReminderEnabled = false
                settingsStore.update(currentSettings())
                statusMessage = "通知权限未开启，请在系统设置中允许通知"
                isNotificationBusy = false
                return
            }

            do {
                let count = try await notificationService.scheduleDailyWaterReminders(settings: currentSettings())
                statusMessage = "提醒已更新，已安排 \(count) 个时间点"
            } catch {
                statusMessage = friendlyMessage(for: error)
            }

            isNotificationBusy = false
        }
    }

    func scheduleTestNotification() {
        isNotificationBusy = true
        statusMessage = "正在安排测试通知"

        Task {
            let granted = await notificationService.requestAuthorization()
            guard granted else {
                statusMessage = "通知权限未开启，请在系统设置中允许通知"
                isNotificationBusy = false
                return
            }

            do {
                try await notificationService.scheduleTestNotification(settings: currentSettings())
                statusMessage = "测试通知已安排，5 秒后送达"
            } catch {
                statusMessage = friendlyMessage(for: error)
            }

            isNotificationBusy = false
        }
    }

    func rescheduleNotifications() {
        guard isReminderEnabled else {
            statusMessage = "请先开启喝水提醒"
            return
        }

        isNotificationBusy = true
        statusMessage = "正在重新生成提醒"

        Task {
            do {
                let count = try await notificationService.scheduleDailyWaterReminders(settings: currentSettings())
                statusMessage = "提醒已重新生成，共 \(count) 个时间点"
            } catch {
                statusMessage = friendlyMessage(for: error)
            }

            isNotificationBusy = false
        }
    }

    func resetToDefaults() {
        let defaultSettings = UserSettings.default
        nickname = defaultSettings.nickname
        dailyTargetAmountML = defaultSettings.dailyTargetAmountML
        defaultDrinkAmountML = defaultSettings.defaultDrinkAmountML
        reminderStartDate = DateUtils.dateForTime(
            hour: defaultSettings.reminderStartHour,
            minute: defaultSettings.reminderStartMinute
        )
        reminderEndDate = DateUtils.dateForTime(
            hour: defaultSettings.reminderEndHour,
            minute: defaultSettings.reminderEndMinute
        )
        reminderIntervalMinutes = defaultSettings.reminderIntervalMinutes
        isReminderEnabled = defaultSettings.isReminderEnabled
        notificationTone = defaultSettings.notificationTone
        settingsStore.resetToDefault()
        statusMessage = "已恢复默认设置"

        Task {
            await notificationService.cancelAllWaterReminders()
        }
    }

    private func save(status: String, shouldReschedule: Bool = true) {
        settingsStore.update(currentSettings())
        statusMessage = status

        if shouldReschedule {
            rescheduleNotificationsAfterSettingsChange()
        }
    }

    private func currentSettings() -> UserSettings {
        let start = DateUtils.hourMinute(from: reminderStartDate)
        let end = DateUtils.hourMinute(from: reminderEndDate)
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        return UserSettings(
            nickname: trimmedNickname.isEmpty ? UserSettings.default.nickname : trimmedNickname,
            dailyTargetAmountML: dailyTargetAmountML,
            defaultDrinkAmountML: defaultDrinkAmountML,
            reminderStartHour: start.hour,
            reminderStartMinute: start.minute,
            reminderEndHour: end.hour,
            reminderEndMinute: end.minute,
            reminderIntervalMinutes: reminderIntervalMinutes,
            isReminderEnabled: isReminderEnabled,
            notificationTone: notificationTone
        )
    }

    private func ensureValidReminderRange(preferMovingEndDate: Bool) {
        let startMinutes = DateUtils.minutesSinceStartOfDay(for: reminderStartDate)
        let endMinutes = DateUtils.minutesSinceStartOfDay(for: reminderEndDate)
        guard startMinutes >= endMinutes else { return }

        if preferMovingEndDate {
            let adjustedEnd = min(startMinutes + 60, 23 * 60 + 59)
            reminderEndDate = DateUtils.dateForTime(hour: adjustedEnd / 60, minute: adjustedEnd % 60)
        } else {
            let adjustedStart = max(endMinutes - 60, 0)
            reminderStartDate = DateUtils.dateForTime(hour: adjustedStart / 60, minute: adjustedStart % 60)
        }
    }

    private func rescheduleNotificationsAfterSettingsChange() {
        guard isReminderEnabled else { return }

        isNotificationBusy = true
        Task {
            do {
                let count = try await notificationService.scheduleDailyWaterReminders(settings: currentSettings())
                statusMessage = "提醒已更新，共 \(count) 个时间点"
            } catch {
                statusMessage = friendlyMessage(for: error)
            }

            isNotificationBusy = false
        }
    }

    private func cancelReminders() {
        isNotificationBusy = true
        Task {
            await notificationService.cancelAllWaterReminders()
            statusMessage = "提醒已关闭"
            isNotificationBusy = false
        }
    }

    private func friendlyMessage(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return error.localizedDescription
    }
}
