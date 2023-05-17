import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func setDateForNewEvent() -> String
    func updateCategories(_ newCategory: TrackerCategory)
}

final class NewTrackerViewController: UIViewController {
    
    public weak var delegate: NewTrackerViewControllerDelegate?
    
    private let trackerType: TrackerType
    
    private var tableTitles: [String] = []
    private var scheduleForTable: String = ""
    private var tableHeight: CGFloat = 0
    
    private var newTrackerName: String = ""
    private var categoryName: String = ""
    private var schedule: [String] = []
    
    init(_ trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
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
        tableView.separatorColor = Color.gray
        tableView.isScrollEnabled = false
        tableView.register(
            NewTrackerSettingsTableViewCell.self,
            forCellReuseIdentifier: NewTrackerSettingsTableViewCell.reuseIdentifier
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
        switchType()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        checkCreateButton()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        
        [viewNameLabel, stackView, tableView, buttonsStackView].forEach {
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
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
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
        guard let date = delegate?.setDateForNewEvent() else { return }
        
        let newTrackerSchedule: [String]
        
        switch trackerType {
        case .habit:
            newTrackerSchedule = self.schedule
        case .event:
            newTrackerSchedule = [date]
        }
        
        let newTracker = Tracker(
            id: UUID(),
            name: newTrackerName,
            color: color,
            emoji: emoji,
            schedule: newTrackerSchedule
        )
        
        let newCategory = TrackerCategory(
            header: categoryName,
            trackers: [newTracker]
        )
        
        delegate?.updateCategories(newCategory)
        
        clearData()
        dismiss(animated: true)
    }
    
    private func clearData() {
        categoryName = ""
        newTrackerName = ""
        scheduleForTable = ""
        schedule = []
    }
    
    private func switchType() {
        switch trackerType {
        case .habit:
            viewNameLabel.text = Constant.newHabitTitle
            tableTitles = Constant.newHabitTableTitles
        case .event:
            viewNameLabel.text = Constant.newEventTitle
            tableTitles = Constant.newEventTableTitles
        }
        tableHeight = CGFloat(tableTitles.count * 75) - 0.5
    }
}

extension NewTrackerViewController {
    private func checkCreateButton() {
        switch trackerType {
        case .habit:
            if newTrackerName != "" && categoryName != "" && scheduleForTable != "" {
                activateCreateButton()
            }
        case .event:
            if newTrackerName != "" && categoryName != "" {
                activateCreateButton()
            }
        }
    }
    
    private func activateCreateButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
            self.createButton.isEnabled = true
            self.createButton.backgroundColor = Color.black
        }
    }
    
    private func deactivateCreateButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
            self.createButton.isEnabled = false
            self.createButton.backgroundColor = Color.gray
        }
    }
}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewTrackerSettingsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? NewTrackerSettingsTableViewCell else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            cell.setDescription(categoryName)
        case 1:
            cell.setDescription(scheduleForTable)
        default:
            break
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.setTitle(tableTitles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            deactivateCreateButton()
            let vc = CategoryViewController()
            vc.completionHandler = { [weak self] category in
                guard let self = self else { return }
                self.categoryName = category
            }
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            deactivateCreateButton()
            let vc = ScheduleViewController()
            vc.completionHandler = { [weak self] schedule in
                guard let self = self else { return }
                self.schedule = schedule
                
                if schedule.count == 7 {
                    self.scheduleForTable = Constant.scheduleVCEverydayDescription
                } else {
                    self.scheduleForTable = self.schedule.joined(separator:", ")
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
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
        checkCreateButton()
        return true
    }
}

extension NewTrackerViewController {
    private func showError() {
        guard errorLabel.isHidden else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.errorLabel.alpha = 1.0
            self.errorLabel.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func hideError() {
        guard !errorLabel.isHidden else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.errorLabel.alpha = 0.0
            self.errorLabel.isHidden = true
            self.stackView.layoutIfNeeded()
        }
    }
}
