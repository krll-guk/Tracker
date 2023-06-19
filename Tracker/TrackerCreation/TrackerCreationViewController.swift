import UIKit

final class TrackerCreationViewController: UIViewController {
    
    public weak var delegate: NewTrackerViewControllerDelegate?
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.trackerCreationVCTitle
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.addArrangedSubview(habitButton)
        stack.addArrangedSubview(eventButton)
        return stack
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.black
        button.layer.cornerRadius = 16
        button.setTitle(Constant.trackerCreationVCHabitButton, for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.titleLabel?.font = Font.medium16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.black
        button.layer.cornerRadius = 16
        button.setTitle(Constant.trackerCreationVCEventButton, for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.titleLabel?.font = Font.medium16
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = Color.white
        
        [viewNameLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // viewNameLabel
            viewNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            viewNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewNameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // stackView
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 31.5),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 136),
        ])
    }
    
    @objc
    private func habitButtonTapped() {
        let vc = NewTrackerViewController(.habit)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func eventButtonTapped() {
        let vc = NewTrackerViewController(.event)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TrackerCreationViewController: NewTrackerViewControllerDelegate{
    func updateCategories(with newTracker: Tracker, _ categoryName: String) {
        delegate?.updateCategories(with: newTracker, categoryName)
    }
    
    func setDateForNewEvent() -> String {
        delegate?.setDateForNewEvent() ?? ""
    }
}
