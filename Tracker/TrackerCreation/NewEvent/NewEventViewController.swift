import UIKit

final class NewEventViewController: UIViewController {
    
    static let didChangeNotification = Notification.Name(rawValue: "NewEventDidChange")
    
    private let titles = Constant.newEventVCTableTitles
    
    private var newTrackerName: String = ""
    private var currentDateString: String = ""

    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.newEventVCTitle
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(errorLabel)
        return stack
    }()
    
    private lazy var textField: UITextField = {
        let textField = CustomTextField(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41))
        textField.backgroundColor = Color.background
        textField.layer.cornerRadius = 16
        textField.font = Font.regular17
        textField.textColor = Color.black
        textField.attributedPlaceholder = NSAttributedString(
            string: Constant.textFieldPlaceholder,
            attributes: [
                .foregroundColor: Color.gray ?? .systemGray,
                .font: Font.regular17,
            ]
        )
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .default
        textField.returnKeyType = .go
        textField.delegate = self
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular17
        label.textColor = Color.red
        label.isHidden = true
        label.alpha = 0.0
        label.text = Constant.errorLabel
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(
            TrackerSettingsTableViewCell.self,
            forCellReuseIdentifier: TrackerSettingsTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = Color.red?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.red, for: .normal)
        button.setTitle(Constant.cancelButton, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.gray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.createButton, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        activateCreateButton()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        
        [viewNameLabel, stackView, tableView, buttonsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [viewNameLabel, stackView, tableView, buttonsStackView].forEach {
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
            stackView.topAnchor.constraint(equalTo: viewNameLabel.bottomAnchor, constant: 38),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // textField
            textField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // errorLabel
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 74),
            
            // buttonsStackView
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc
    private func cancelButtonTapped() {
        clearData()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func createButtonTapped() {
        guard let color = Color.colorSelectionArray.randomElement()! else { return }
        guard let emoji = Constant.emojis.randomElement() else { return }
        
        currentDateString = AppDateFormatter.shared.dateString(from: Date())
        
        let newTracker = Tracker(
            id: UUID(),
            name: newTrackerName,
            color: color,
            emoji: emoji,
            schedule: [currentDateString]
        )
        
        TrackersViewController.newCategory = TrackerCategory(
            header: CategoryViewController.category,
            trackers: [newTracker]
        )
        
        NotificationCenter.default.post(
            name: NewEventViewController.didChangeNotification,
            object: self,
            userInfo: nil
        )
        
        clearData()
        dismiss(animated: true)
    }
    
    private func clearData() {
        CategoryViewController.category = ""
        newTrackerName = ""
        currentDateString = ""
    }
}

extension NewEventViewController {
    private func activateCreateButton() {
        if newTrackerName != "" && CategoryViewController.category != "" {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
                self.createButton.isEnabled = true
                self.createButton.backgroundColor = Color.black
            }
        }
    }
    
    private func deactivateCreateButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
            self.createButton.isEnabled = false
            self.createButton.backgroundColor = Color.gray
        }
    }
}

extension NewEventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerSettingsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerSettingsTableViewCell else { return UITableViewCell() }
        
        cell.setDescription(CategoryViewController.category)
        
        cell.setTitle(titles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deactivateCreateButton()
        navigationController?.pushViewController(CategoryViewController(), animated: true)
    }
}

extension NewEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 38
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        if newString.count >= maxLength {
            showError()
        } else {
            hideError()
        }
        
        return newString.count <= maxLength
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        newTrackerName = ""
        hideError()
        deactivateCreateButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        newTrackerName = textField.text ?? ""
        hideError()
        activateCreateButton()
        return true
    }
}

extension NewEventViewController {
    private func showError() {
        if errorLabel.isHidden {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.errorLabel.alpha = 1.0
                self.errorLabel.isHidden = false
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    private func hideError() {
        if !errorLabel.isHidden {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.errorLabel.alpha = 0.0
                self.errorLabel.isHidden = true
                self.stackView.layoutIfNeeded()
            }
        }
    }
}
