import UIKit

final class TrackerSupplementaryView: UICollectionReusableView {
    
    static let reuseIdentifier = "TrackerSupplementaryViewHeader"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold19
        label.tintColor = Color.black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
