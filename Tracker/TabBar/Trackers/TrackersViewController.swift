import UIKit

final class TrackersViewController: UIViewController {
    
    static var newCategory: TrackerCategory?
    static var dateForNewEvent = ""
    
    private var newHabitObserver: NSObjectProtocol?
    private var newEventObserver: NSObjectProtocol?
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var visibleCategoriesForSearch: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var datePickerDateString: String = ""
    private var weekDayString: String = ""
    private var currentDateString: String = ""
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constant.trackersVCSearchBarPlaceholder
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(updateVisibleCategories), for: .valueChanged)
        return datePicker
    }()
    
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
        image.image = Image.star
        return image
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Font.medium12
        label.textColor = Color.black
        label.text = Constant.trackersVCEmptyLabelText
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.reuseIdentifier
        )
        collectionView.backgroundColor = Color.white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkPlaceholderVisibility()
        setNotifications()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        title = Constant.leftTabBarTitle
        
        [placeholderStackView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [placeholderStackView, collectionView].forEach {
            view.addSubview($0)
        }
        
        setConstraints()
        setupNavigationBar()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // stackView
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            // collectionView
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        navigationItem.leftBarButtonItem?.tintColor = Color.black
        navigationController?.navigationBar.backgroundColor = Color.white
    }
    
    @objc private func addButtonTapped() {
        let navigationController = UINavigationController(rootViewController: TrackerCreationViewController())
        present(navigationController, animated: true)
    }
    
    private func setNotifications() {
        newHabitObserver = NotificationCenter.default.addObserver(
            forName: NewHabitViewController.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateCategories()
        }
        
        newEventObserver = NotificationCenter.default.addObserver(
            forName: NewEventViewController.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateCategories()
        }
    }
    
    private func checkPlaceholderVisibility() {
        if visibleCategories.isEmpty {
            imageView.image = Image.star
            label.text = Constant.trackersVCEmptyLabelText
            
            collectionView.isHidden = true
            placeholderStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            placeholderStackView.isHidden = true
        }
    }
}

extension TrackersViewController {
    private func updateCategories() {
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
        
        updateVisibleCategories()
    }
    
    @objc
    private func updateVisibleCategories() {
        weekDayString = AppDateFormatter.shared.weekDayString(from: datePicker.date)
        datePickerDateString = AppDateFormatter.shared.dateString(from: datePicker.date)
        currentDateString = AppDateFormatter.shared.dateString(from: Date())
        
        TrackersViewController.dateForNewEvent = datePickerDateString
        
        visibleCategories = []
        var trackers: [Tracker] = []
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.schedule.contains(where: { $0 == weekDayString || $0 == datePickerDateString }) {
                    trackers.append(tracker)
                }
            }
            
            if !trackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: trackers)
                visibleCategories.append(newCategory)
            }
            
            trackers = []
        }
        
        visibleCategoriesForSearch = visibleCategories

        if searchController.isActive {
            searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
        } else {
            checkPlaceholderVisibility()
            collectionView.reloadData()
        }
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        let newRecord = TrackerRecord(id: id, date: datePickerDateString)
        
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCollectionViewCell
        
        cell.delegate = self
        
        cell.set(visibleCategories[indexPath.section].trackers[indexPath.row])
        
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        
        if completedTrackers.contains(where: {
            $0.id == id &&
            $0.date == datePickerDateString })
        {
            cell.trackerIsCompleted(true)
        } else {
            cell.trackerIsCompleted(false)
        }
        
        var quantity = 0
        completedTrackers.forEach({
            if $0.id == id {
                quantity += 1
            }
        })
        cell.setQuantity(quantity)
        
        if datePickerDateString > currentDateString {
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
            id = SupplementaryView.reuseIdentifier
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        
        let title = visibleCategories[indexPath.section].header
        view.setTitle(title)
        
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
            filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        var searchCategories: [TrackerCategory] = []
        var trackers: [Tracker] = []
        
        for category in visibleCategoriesForSearch {
            for tracker in category.trackers {
                if tracker.name.lowercased().contains(searchText.lowercased()) || searchText == "" {
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
        checkPlaceholderVisibility()
        
        if visibleCategories.isEmpty && !visibleCategoriesForSearch.isEmpty {
            imageView.image = Image.error
            label.text = Constant.trackersVCErrorLabelText
        }
        
        collectionView.reloadData()
    }
}
