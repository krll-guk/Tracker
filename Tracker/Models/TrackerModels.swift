import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: String
    let date: String
    let pinned: Bool
    var quantity = 0
}

struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: String
}

enum TrackerType {
    case habit
    case event
}

enum StoreError: Error {
    case decodeError
}
