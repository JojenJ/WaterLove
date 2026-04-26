import Foundation

enum NotificationTone: String, CaseIterable, Codable, Identifiable {
    case sweet
    case playful
    case gentlePush
    case caring

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sweet:
            "甜甜模式"
        case .playful:
            "俏皮模式"
        case .gentlePush:
            "轻微催促模式"
        case .caring:
            "温柔陪伴模式"
        }
    }
}

struct UserSettings: Codable, Equatable {
    var nickname: String
    var dailyTargetAmountML: Int
    var defaultDrinkAmountML: Int
    var reminderStartHour: Int
    var reminderStartMinute: Int
    var reminderEndHour: Int
    var reminderEndMinute: Int
    var reminderIntervalMinutes: Int
    var isReminderEnabled: Bool
    var notificationTone: NotificationTone

    static let `default` = UserSettings(
        nickname: "宝宝",
        dailyTargetAmountML: 1800,
        defaultDrinkAmountML: 200,
        reminderStartHour: 9,
        reminderStartMinute: 0,
        reminderEndHour: 22,
        reminderEndMinute: 0,
        reminderIntervalMinutes: 60,
        isReminderEnabled: false,
        notificationTone: .playful
    )
}
