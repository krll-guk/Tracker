import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    public weak var delegate: TrackerCategoryStoreDelegate?
    
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
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
            let schedule = data.schedule,
            let date = data.date
        else {
            throw StoreError.decodeError
        }
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: color),
            emoji: emoji,
            schedule: schedule,
            date: date,
            pinned: data.pinned
        )
    }
    
    func newTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.date = tracker.date
        trackerCoreData.pinned = tracker.pinned
        return trackerCoreData
    }
    
    func changeTracker(_ newTracker: Tracker, _ categoryName: String) throws {
        guard let tracker = fetchedResultsController.fetchedObjects?.first(where: {
            $0.id == newTracker.id }) else { return }
        tracker.name = newTracker.name
        tracker.color = uiColorMarshalling.hexString(from: newTracker.color)
        tracker.schedule = newTracker.schedule
        tracker.emoji = newTracker.emoji
        tracker.category = TrackerCategoryStore().category(categoryName)
        try context.save()
    }
    
    func pined(_ tracker: Tracker) throws {
        guard let tracker = fetchedResultsController.fetchedObjects?.first(where: {
            $0.id == tracker.id }) else { return }
        tracker.pinned = !tracker.pinned
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let tracker = fetchedResultsController.fetchedObjects?.first(where: {
            $0.id == tracker.id }) else { return }
        context.delete(tracker)
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
