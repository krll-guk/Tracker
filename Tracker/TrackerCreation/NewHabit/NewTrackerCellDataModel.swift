import Foundation

struct NewTrackerCellDataModel {
    var title: String = ""
    var description: String = ""
    var isHidden = false
    
    static let data: [NewTrackerCellDataModel] = [
        NewTrackerCellDataModel(title: "Категория", description: "Other"),
        NewTrackerCellDataModel(title: "Расписание", description: "Пн, Вт"),
    ]
}
