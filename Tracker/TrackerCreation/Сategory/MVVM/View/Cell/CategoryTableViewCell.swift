import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryTableViewCell"
 
    var cellViewModel: CategoryModel? {
        didSet {
            textLabel?.text = cellViewModel?.categoryName
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        backgroundColor = Color.background
        selectionStyle = .none
        textLabel?.font = Font.regular17
        textLabel?.textColor = Color.black
    }
}
