import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    
    convenience override init() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("could not get app delegate")
        }
        let context = delegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    func tracker(from data: NSSet.Element) throws -> Tracker {
        guard let data = data as? TrackerCoreData else {
            throw StoreError.decodeError
        }
        guard
            let id = data.id,
            let name = data.name,
            let color = data.color,
            let emoji = data.emoji,
            let schedule = data.schedule
        else {
            throw StoreError.decodeError
        }
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: color),
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func newTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        return trackerCoreData
    }
}
