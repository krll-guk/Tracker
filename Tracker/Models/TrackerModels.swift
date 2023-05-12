import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [String]
}

struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: String
}

enum WeekDay: String, CaseIterable {
    case Пн, Вт, Ср, Чт, Пт, Сб, Вс
}
