import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: String
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
    case Monday = "Пн"
    case Tuesday = "Вт"
    case Wednesday = "Ср"
    case Thursday = "Чт"
    case Friday = "Пт"
    case Saturday = "Сб"
    case Sunday = "Вс"
}

enum TrackerType {
    case habit
    case event
}

enum StoreError: Error {
    case decodeError
}
