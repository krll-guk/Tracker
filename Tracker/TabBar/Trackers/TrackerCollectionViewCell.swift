import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var days: [String] = ["дней", "день", "дня"]
    private var quantity: Int = 0
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.text = "Кошка заслонила камеру на созвоне"
        label.addInterlineSpacing(spacingValue: 18 - label.font.lineHeight)
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "❤️"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var quantityButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
//        button.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .disabled)
        button.setPreferredSymbolConfiguration((.init(pointSize: 12)), forImageIn: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = "\(quantity) \(days[0])"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        switchDay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        setupTrackerBackgroundView()
        setupEmojiLabel()
        setupTextLabel()
        setupQuantityButton()
        setupQuantityLabel()
    }
    
    private func setupTrackerBackgroundView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setupEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupTextLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupQuantityButton() {
        quantityButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityButton)
        
        NSLayoutConstraint.activate([
            quantityButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            quantityButton.heightAnchor.constraint(equalToConstant: 34),
            quantityButton.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        quantityButton.addTarget(self, action: #selector(checkMark), for: .touchUpInside)
    }
    
    private func setupQuantityLabel() {
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityLabel)
        
        NSLayoutConstraint.activate([
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.trailingAnchor.constraint(equalTo: quantityButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityButton.centerYAnchor)
        ])
    }
    
    @objc
    private func checkMark() {
        switch quantityButton.currentImage {
        case UIImage(systemName: "plus"):
//            quantityButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
//            quantityButton.alpha = 0.3
            doneCheck(true)
            quantity += 1
            switchDay()
            delegate?.record(true, self)
        case UIImage(systemName: "checkmark"):
//            quantityButton.setImage(UIImage(systemName: "plus"), for: .normal)
//            quantityButton.alpha = 1
            doneCheck(false)
            quantity -= 1
            switchDay()
            delegate?.record(false, self)
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    private func switchDay() {
        switch quantity {
        case 1:
            quantityLabel.text = "\(quantity) \(days[1])"
        case 2...4:
            quantityLabel.text = "\(quantity) \(days[2])"
        default:
            quantityLabel.text = "\(quantity) \(days[0])"
        }
        
        if quantity % 10 == 1 && !(quantity % 100 == 11) {
            quantityLabel.text = "\(quantity) \(days[1])"
        }
        
        for i in 2...4 {
            if quantity % 10 == i && !(quantity % 100 == i + 10) {
                quantityLabel.text = "\(quantity) \(days[2])"
            }
        }
    }
    
    func set(_ model: Tracker) {
        nameLabel.text = model.name
        colorView.backgroundColor = model.color
        quantityButton.backgroundColor = model.color
        emojiLabel.text = model.emoji
    }
    
    func doneCheck(_ sender: Bool) {
        switch sender {
        case true:
            quantityButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            quantityButton.alpha = 0.3
        case false:
            quantityButton.setImage(UIImage(systemName: "plus"), for: .normal)
            quantityButton.alpha = 1
        }
    }
    
    func buttonIsEnabled(_ sender: Bool) {
        switch sender {
        case true:
            quantityButton.isEnabled = true
        case false:
            quantityButton.isEnabled = false
            quantityButton.alpha = 0
        }
        
//        quantityButton.isEnabled = sender
    }
    
    func setQuantity(_ sender: Int) {
        quantity = sender
        switchDay()
    }
}
