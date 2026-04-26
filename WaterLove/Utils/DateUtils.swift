import Foundation

enum DateUtils {
    static func isSameDay(_ firstDate: Date, _ secondDate: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(firstDate, inSameDayAs: secondDate)
    }

    static func startOfDay(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }
}
