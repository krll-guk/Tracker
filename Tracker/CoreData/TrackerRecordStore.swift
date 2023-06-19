import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    
    public weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    var completedTrackers: Set<TrackerRecord> {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let completedTrackers = try? objects.map({ try self.completedTracker(from: $0)})
        else { return [] }
        return Set(completedTrackers)
    }
    
    private func completedTracker(from data: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = data.id,
            let date = data.date
        else {
            throw StoreError.decodeError
        }
        return TrackerRecord(
            id: id,
            date: date
        )
    }
    
    func addRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.id = trackerRecord.id
        try context.save()
    }
    
    func removeRecord(_ trackerRecord: TrackerRecord) throws {
        guard let record = fetchedResultsController.fetchedObjects?.first(where: {
            $0.id == trackerRecord.id && $0.date == trackerRecord.date
        }) else { return }
        context.delete(record)
        try context.save()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
