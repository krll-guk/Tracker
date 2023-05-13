import Foundation

final class AppDateFormatter {
    static let shared = AppDateFormatter()
    
    private lazy var dateFormatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var dateFormatterWeekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()

    func dateString(from date: Date) -> String {
        return dateFormatterDate.string(from: date)
    }
    
    func weekDayString(from date: Date) -> String {
        return dateFormatterWeekDay.string(from: date)
    }
}
