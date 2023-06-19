import UIKit

final class NewTrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NewTrackerCollectionViewCell"
    
    private lazy var emojiPickView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = Color.lightGray
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold32
        label.textAlignment = .center
        return label
    }()
    
    private lazy var colorPickView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 11
        view.layer.borderWidth = 3
        view.alpha = 0.3
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if !emojiLabel.isHidden {
                self.emojiPickView.isHidden = isSelected ? false : true
            }
            if !colorView.isHidden {
                self.colorPickView.isHidden = isSelected ? false : true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        
        [emojiPickView, emojiLabel, colorPickView, colorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
            contentView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // emojiPickView
            emojiPickView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiPickView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiPickView.heightAnchor.constraint(equalToConstant: 52),
            emojiPickView.widthAnchor.constraint(equalToConstant: 52),
            
            // emojiLabel
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // colorPickView
            colorPickView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorPickView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorPickView.heightAnchor.constraint(equalToConstant: 52),
            colorPickView.widthAnchor.constraint(equalToConstant: 52),
            
            // colorView
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func setEmoji(_ model: String) {
        emojiLabel.text = model
        emojiLabel.isHidden = false
    }
    
    func setColor(_ model: UIColor) {
        colorView.backgroundColor = model
        colorView.isHidden = false
        colorPickView.layer.borderColor = model.cgColor
    }
}
