import UIKit

final class TrackersViewController: UIViewController {
    
    public lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    private var newTrackerObserver: NSObjectProtocol?
    
    static var newCategory: TrackerCategory?
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(updateCategories), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.addArrangedSubview(errorImageView)
        stack.addArrangedSubview(errorLabel)
        return stack
    }()
    
    private lazy var errorImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Star")
        return image
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.font = Font.medium12
        label.textColor = .black
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideCollectionView()
        
        newTrackerObserver = NotificationCenter.default.addObserver(
            forName: NewHabitViewController.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.addTracker()
            self.updateCategories()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Трекеры"
        setupNavigationBar()
        setupStackView()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func addButtonTapped() {
        let navigationController = UINavigationController(rootViewController: TrackerCreationViewController())
        present(navigationController, animated: true)
    }
    
    private func hideCollectionView() {
        if visibleCategories.isEmpty {
            errorImageView.image = UIImage(named: "Star")
            errorLabel.text = "Что будем отслеживать?"
            
            collectionView.isHidden = true
            stackView.isHidden = false
        } else {
            collectionView.isHidden = false
            stackView.isHidden = true
        }
    }
}

extension TrackersViewController {
    func addTracker() {
        if let newCategory = TrackersViewController.newCategory {
            if categories.isEmpty {
                categories.insert(newCategory, at: 0)
            } else {
                for category in categories {
                    if category.header == newCategory.header {
                        let updatedCategory = TrackerCategory(
                            header: newCategory.header,
                            trackers: newCategory.trackers + category.trackers
                        )
                        categories.removeAll { $0.header == updatedCategory.header }
                        categories.insert(updatedCategory, at: 0)
                    }
                }
                
                if !categories.contains(where: { $0.header == newCategory.header }) {
                    categories.insert(newCategory, at: 0)
                }
            }
        }
    }
    
    @objc
    private func updateCategories() {
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        print(dayOfTheWeekString)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDayString = dateFormatter.string(from: date)
        
        visibleCategories = []
        var trackers: [Tracker] = []
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.schedule.contains(where: { $0 == dayOfTheWeekString || $0 == currentDayString }) {
                    trackers.append(tracker)
                }
            }
            
            if !trackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: trackers)
                visibleCategories.append(newCategory)
            }
            
            trackers = []
        }
        
        hideCollectionView()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)
        let newRecord = TrackerRecord(id: id, date: dateString)
        
        switch sender {
        case true:
            completedTrackers.insert(newRecord)
        case false:
            completedTrackers.remove(newRecord)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.delegate = self
        
        cell.set(visibleCategories[indexPath.section].trackers[indexPath.row])
        
        if completedTrackers.contains(where: {
            $0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id &&
            $0.date == dateFormatter.string(from: datePicker.date) })
        {
            cell.doneCheck(true)
        } else {
            cell.doneCheck(false)
        }
        
        var quantity = 0
        completedTrackers.forEach({
            if $0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id {
                quantity += 1
            }
        })
        cell.setQuantity(quantity)
        
        if dateFormatter.string(from: datePicker.date) > dateFormatter.string(from: currentDate) {
            cell.buttonIsEnabled(false)
        } else {
            cell.buttonIsEnabled(true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.titleLabel.text = visibleCategories[indexPath.section].header
        view.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        var height = CGFloat()
        if section == 0 {
            height = 42
        } else {
            height = 34
        }
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9 - 16 - 16) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            updateCategories()
        } else {
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        print(dayOfTheWeekString)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDayString = dateFormatter.string(from: date)
        
        var searchCategories: [TrackerCategory] = []
        var trackers: [Tracker] = []
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.name.lowercased().contains(searchText.lowercased()) && tracker.schedule.contains(where: { $0 == dayOfTheWeekString || $0 == currentDayString}) {
                    trackers.append(tracker)
                }
            }
            
            if !trackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: trackers)
                searchCategories.append(newCategory)
            }
            
            trackers = []
        }
        visibleCategories = searchCategories
        hideCollectionView()
        
        if visibleCategories.isEmpty {
            errorImageView.image = UIImage(named: "Error")
            errorLabel.text = "Ничего не найдено"
        }
        
        collectionView.reloadData()
    }
}
