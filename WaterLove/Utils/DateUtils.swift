import Foundation

enum DateUtils {
    static func isSameDay(_ firstDate: Date, _ secondDate: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(firstDate, inSameDayAs: secondDate)
    }

    static func startOfDay(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func timeText(from date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func shortDateText(from date: Date) -> String {
        date.formatted(.dateTime.month(.twoDigits).day(.twoDigits))
    }

    static func weekdayText(from date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    static func dateForTime(hour: Int, minute: Int, calendar: Calendar = .current) -> Date {
        let now = Date()
        let safeHour = min(max(hour, 0), 23)
        let safeMinute = min(max(minute, 0), 59)

        return calendar.date(
            bySettingHour: safeHour,
            minute: safeMinute,
            second: 0,
            of: now
        ) ?? now
    }

    static func hourMinute(from date: Date, calendar: Calendar = .current) -> (hour: Int, minute: Int) {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0, components.minute ?? 0)
    }

    static func minutesSinceStartOfDay(for date: Date, calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}
