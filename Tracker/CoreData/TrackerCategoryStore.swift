import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    
    public weak var delegate: TrackerCategoryStoreDelegate?
    
    private let trackerStore = TrackerStore()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)
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
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackerCategories = try? objects.map({ try self.trackerCategory(from: $0)})
        else { return [] }
        return trackerCategories
    }
    
    private func trackerCategory(from data: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = data.header else {
            throw StoreError.decodeError
        }
        let trackers: [Tracker] = try data.trackers?.map({ try trackerStore.tracker(from: $0) }) ?? []
        return TrackerCategory(
            header: header,
            trackers: trackers.sorted(by: { $0.name < $1.name})
        )
    }
    
    func addNewCategory(_ categoryName: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.header = categoryName
        try context.save()
    }
    
    func addNewTracker(_ tracker: Tracker, to trackerCategory: String) throws {
        let category = fetchedResultsController.fetchedObjects?.first(where: { $0.header == trackerCategory })
        let tracker = trackerStore.newTracker(from: tracker)
        category?.addToTrackers(tracker)
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
