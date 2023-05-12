import UIKit

final class NewTrackerTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "NewTrackerTableViewCell"
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descriptionLabel)
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular17
        label.textColor = Color.black
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular17
        label.textColor = Color.gray
        label.isHidden = true
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Color.gray
        imageView.contentMode = .center
        return imageView
    }()
    
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
        
        [stackView, chevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [stackView, chevronImageView].forEach {
            contentView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // stackView
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 46),
            
            // chevronImageView
            chevronImageView.heightAnchor.constraint(equalToConstant: 24),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func setTitle(_ model: String) {
        titleLabel.text = model
    }
    
    func setDescription(_ model: String) {
        descriptionLabel.text = model
        if descriptionLabel.text != "" {
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
}
