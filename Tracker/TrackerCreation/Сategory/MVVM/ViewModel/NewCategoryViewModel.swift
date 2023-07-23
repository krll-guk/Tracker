import Foundation

final class NewCategoryViewModel {
    private(set) var categories: [CategoryModel] = []
    
    private let trackerCategoryStore: TrackerCategoryStore
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        self.init(trackerCategoryStore: trackerCategoryStore)
    }
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        getCategories()
    }
    
    func addNewCategory(_ category: CategoryModel) {
        do {
            try trackerCategoryStore.addNewCategory(category)
        } catch {}
    }
    
    private func getCategories() {
        categories = trackerCategoryStore.trackerCategories.map { CategoryModel(categoryName: $0.header) }
    }
}

extension NewCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        getCategories()
    }
}
