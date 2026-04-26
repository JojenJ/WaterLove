import Foundation
import Observation

@Observable
final class SettingsViewModel {
    let reminderIntervalOptions = [30, 60, 120]

    private let settingsStore: UserSettingsStore

    var nickname: String
    var dailyTargetAmountML: Int
    var defaultDrinkAmountML: Int
    var reminderStartDate: Date
    var reminderEndDate: Date
    var reminderIntervalMinutes: Int
    var isReminderEnabled: Bool
    var notificationTone: NotificationTone
    var statusMessage = "设置已保存"

    init(settingsStore: UserSettingsStore) {
        self.settingsStore = settingsStore

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
        save(status: newValue ? "提醒已开启" : "提醒已关闭")
    }

    func updateNotificationTone(_ newValue: NotificationTone) {
        notificationTone = newValue
        save(status: "通知语气已保存")
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
    }

    private func save(status: String) {
        settingsStore.update(currentSettings())
        statusMessage = status
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
}
