import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func setDateForNewEvent() -> String
    func updateCategories(with newTracker: Tracker, _ categoryName: String)
    func changeTracker(_ tracker: Tracker, _ categoryName: String)
}

final class NewTrackerViewController: UIViewController {
    
    public weak var delegate: NewTrackerViewControllerDelegate?
    
    private let trackerType: TrackerType
    private let pickedTracker: TrackerCategory?
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var selectedSchedule: [String: String] = [:]
    
    private var tableTitles: [String] = []
    private var scheduleForTable: String = ""
    private var tableHeight: CGFloat = 0
    
    private var newTrackerName: String = ""
    private var categoryName: String = ""
    private var schedule: String = ""
    private var color: UIColor?
    private var emoji: String?
    private var date: String?
    private var id: UUID?
    
    init(_ pickedTracker: TrackerCategory?, _ trackerType: TrackerType) {
        self.pickedTracker = pickedTracker
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
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold32
        label.textColor = Color.black
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(daysLabel)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(errorLabel)
        stack.setCustomSpacing(40, after: daysLabel)
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
            NewTrackerTableViewCell.self,
            forCellReuseIdentifier: NewTrackerTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            NewTrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: NewTrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            NewTrackerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NewTrackerSupplementaryView.reuseIdentifier
        )
        collectionView.backgroundColor = Color.white
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        return collectionView
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
        hideKeyboardWhenTappedAround()
        switchType()
        checkPickedTracker()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        checkCreateButton()
    }
    
    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = Color.white
        
        [viewNameLabel, scrollView, buttonsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        [stackView, tableView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // viewNameLabel
            viewNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            viewNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewNameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // buttonsStackView
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // scrollView
            scrollView.topAnchor.constraint(equalTo: viewNameLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            // containerView
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: collectionView.heightAnchor),
            
            // stackView
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            //daysLabel
            daysLabel.heightAnchor.constraint(equalToConstant: 38),
            
            // textField
            textField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // errorLabel
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            // collectionView
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 476),
        ])
    }
    
    private func checkPickedTracker() {
        if let pickedTracker = pickedTracker {
            guard let tracker = pickedTracker.trackers.first else { return }
            id = tracker.id
            textField.text = tracker.name
            newTrackerName = tracker.name
            categoryName = pickedTracker.header
            color = tracker.color
            emoji = tracker.emoji
            schedule = tracker.schedule
            date = tracker.date
            selectedSchedule = Constant.weekDays.filter({ schedule.contains($0.key) })
            
            let sortedSchedule = Constant.weekDays.filter({ schedule.contains($0.key) }).sorted(by: { $0.key < $1.key })
            
            if sortedSchedule.count == 7 {
                scheduleForTable = Constant.scheduleVCEverydayDescription
            } else {
                scheduleForTable = Array(sortedSchedule.map({ $0.value })).joined(separator:", ")
            }
            
            viewNameLabel.text = Constant.editTrackerTitle
            createButton.setTitle(Constant.saveButton, for: .normal)
            
            daysLabel.isHidden = false
            daysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: ""), tracker.quantity
            )
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        if pickedTracker == nil {
            navigationController?.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc
    private func createButtonTapped() {
        if pickedTracker == nil {
            self.date = delegate?.setDateForNewEvent()
            self.id = UUID()
        }
        
        guard
            let color = self.color,
            let emoji = self.emoji,
            let date = self.date,
            let id = self.id
        else { return }
        
        let newTracker: Tracker
        
        switch trackerType {
        case .habit:
            newTracker = Tracker(
                id: id,
                name: newTrackerName,
                color: color,
                emoji: emoji,
                schedule: schedule,
                date: "",
                pinned: false
            )
        case .event:
            newTracker = Tracker(
                id: id,
                name: newTrackerName,
                color: color,
                emoji: emoji,
                schedule: "",
                date: date,
                pinned: false
            )
        }
        
        if pickedTracker == nil {
            delegate?.updateCategories(with: newTracker, categoryName)
        } else {
            delegate?.changeTracker(newTracker, categoryName)
        }
        dismiss(animated: true)
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
            if newTrackerName != "" && categoryName != "" && scheduleForTable != "" &&
                color != nil && emoji != nil {
                activateCreateButton()
            }
        case .event:
            if newTrackerName != "" && categoryName != "" &&
                color != nil && emoji != nil {
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
            withIdentifier: NewTrackerTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? NewTrackerTableViewCell else { return UITableViewCell() }
        
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
            let vc = CategoryViewController(categoryName)
            vc.completionHandler = { [weak self] category in
                guard let self = self else { return }
                self.categoryName = category
            }
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            deactivateCreateButton()
            let vc = ScheduleViewController(selectedSchedule)
            vc.completionHandler = { [weak self] pickedSchedule in
                guard let self = self else { return }
                self.selectedSchedule = pickedSchedule
                
                let sortedSchedule = Array(pickedSchedule.sorted { $0.key < $1.key })
                self.schedule = Array(sortedSchedule.map({ $0.key })).joined(separator:", ")
                
                if sortedSchedule.count == 7 {
                    self.scheduleForTable = Constant.scheduleVCEverydayDescription
                } else {
                    self.scheduleForTable = Array(sortedSchedule.map({ $0.value })).joined(separator:", ")
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Constant.emojis.count
        case 1:
            return Color.colorSelectionArray.count
        default:
            return 18
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewTrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? NewTrackerCollectionViewCell else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0:
            cell.setEmoji(Constant.emojis[indexPath.row])
            if emoji == Constant.emojis[indexPath.row] {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            }
        case 1:
            guard let color = Color.colorSelectionArray[indexPath.row] else { break }
            cell.setColor(color)
            
            guard let pickedColor = self.color else { break }
            if uiColorMarshalling.hexString(from: pickedColor) == uiColorMarshalling.hexString(from: color) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            }
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = NewTrackerSupplementaryView.reuseIdentifier
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! NewTrackerSupplementaryView
        
        let title = Constant.collectionViewTitles[indexPath.section]
        view.setTitle(title)
        
        return view
    }
}

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: 34),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 19, bottom: 24, right: 19)
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({
            $0.section == indexPath.section
        }).forEach({
            collectionView.deselectItem(at: $0, animated: true)
        })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            emoji = Constant.emojis[indexPath.row]
        case 1:
            color = Color.colorSelectionArray[indexPath.row]
        default:
            break
        }
        checkCreateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            emoji = nil
        case 1:
            color = nil
        default:
            break
        }
        deactivateCreateButton()
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
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        newTrackerName = textField.text ?? ""
        checkCreateButton()
        hideError()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        deactivateCreateButton()
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
