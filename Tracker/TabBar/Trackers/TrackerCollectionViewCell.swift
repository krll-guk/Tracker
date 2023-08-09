import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var quantity: Int = 0
    
    var menu: UIView {
        return colorView
    }
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Image.pin
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium12
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.font = Font.medium12
        label.textAlignment = .center
        return label
    }()
    
    private lazy var quantityButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.setPreferredSymbolConfiguration((.init(pointSize: 12)), forImageIn: .normal)
        button.tintColor = Color.white
        button.addTarget(self, action: #selector(quantityButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium12
        label.textColor = Color.black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        
        [colorView, emojiLabel, nameLabel, quantityButton, quantityLabel, pinImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [colorView, quantityButton, quantityLabel].forEach {
            contentView.addSubview($0)
        }
        
        [emojiLabel, nameLabel, pinImageView].forEach {
            colorView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // colorView
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            // emojiLabel
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            // nameLabel
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            // quantityButton
            quantityButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            quantityButton.heightAnchor.constraint(equalToConstant: 34),
            quantityButton.widthAnchor.constraint(equalToConstant: 34),
            
            //
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.trailingAnchor.constraint(equalTo: quantityButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityButton.centerYAnchor),
            
            //pinedImageView
            pinImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -4),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    @objc
    private func quantityButtonTapped() {
        switch quantityButton.currentImage {
        case Image.plus:
            trackerIsCompleted(true)
            quantity += 1
            setQuantityLabelText()
            delegate?.record(true, self)
        case Image.checkMark:
            trackerIsCompleted(false)
            quantity -= 1
            setQuantityLabelText()
            delegate?.record(false, self)
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    private func setQuantityLabelText() {
        quantityLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""), quantity
        )
    }
    
    func set(_ model: Tracker) {
        nameLabel.text = model.name
        colorView.backgroundColor = model.color
        quantityButton.backgroundColor = model.color
        emojiLabel.text = model.emoji
        
        nameLabel.addInterlineSpacing(spacingValue: 18 - nameLabel.font.lineHeight)
    }
    
    func trackerIsCompleted(_ sender: Bool) {
        switch sender {
        case true:
            quantityButton.setImage(Image.checkMark, for: .normal)
            quantityButton.alpha = 0.3
        case false:
            quantityButton.setImage(Image.plus, for: .normal)
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
    }
    
    func setQuantity(_ sender: Int) {
        quantity = sender
        setQuantityLabelText()
    }
    
    func pinned(_ sender: Bool) {
        pinImageView.isHidden = !sender
    }
}
