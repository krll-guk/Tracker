import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: Set<TrackerRecord> = []
    
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(label)
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = Image.statistics
        return image
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Font.medium12
        label.textColor = Color.black
        label.text = Constant.statisticsVCPlaceholder
        label.numberOfLines = 0
        label.addInterlineSpacing(spacingValue: 18 - label.font.lineHeight)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold34
        label.textColor = Color.black
        return label
    }()
    
    private lazy var cardLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium12
        label.textColor = Color.black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerRecordStore.delegate = self
        checkPlaceholderVisibility()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.frame = cardView.bounds
        gradient.colors = Color.gradientColors as [Any]
        gradient.cornerRadius = cardView.layer.cornerRadius
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        cardView.layer.addSublayer(gradient)
        
        let background = CALayer()
        background.frame = cardView.bounds.insetBy(dx: 1, dy: 1)
        background.cornerRadius = cardView.layer.cornerRadius - 0.5
        background.backgroundColor = Color.white?.cgColor
        cardView.layer.insertSublayer(background, above: gradient)
        
        cardView.bringSubviewToFront(cardLabel)
        cardView.bringSubviewToFront(cardNumberLabel)
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        title = Constant.rightTabBarTitle
        
        [cardView, placeholderStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [cardNumberLabel, cardLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        
        setConstraints()
        setupNavigationBar()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // stackView
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            // cardView
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // cardNumberLabel
            cardNumberLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardNumberLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            // cardLabel
            cardLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            cardLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = Color.white
    }
    
    private func checkPlaceholderVisibility() {
        completedTrackers = trackerRecordStore.completedTrackers
        
        let quantity = completedTrackers.count
        cardLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("trackersStatistics", comment: ""), quantity
        )
        cardNumberLabel.text = "\(quantity)"
        
        if completedTrackers.isEmpty {
            placeholderStackView.isHidden = false
            cardView.isHidden = true
        } else {
            placeholderStackView.isHidden = true
            cardView.isHidden = false
        }
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        checkPlaceholderVisibility()
    }
}
