import Foundation

final class CategoryViewModel {
    @Observable
    private(set) var categories: [CategoryModel] = []
    
    @Observable
    private(set) var selectedCategory: CategoryModel?
    
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
    
    func selected(categoryName: String) {
        selectedCategory = CategoryModel(categoryName: categoryName)
        UserDefaults.standard.set(categoryName, forKey: "selectedCategory")
    }
    
    private func getCategories() {
        categories = trackerCategoryStore.trackerCategories.map { CategoryModel(categoryName: $0.header) }
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        getCategories()
    }
}
