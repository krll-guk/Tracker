import UIKit

final class TrackersViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let analyticsService = AnalyticsService()

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var visibleCategoriesForSearch: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var filter = Filter.allTrackers
    private var filteredCategories: [TrackerCategory] = []
    
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
        datePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
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
            TrackerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier
        )
        collectionView.backgroundColor = Color.white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.blue
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.regular17
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.filtersVCTitle, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        syncData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open, params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, params: ["screen": "Main"])
    }
    
    private func syncData() {
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        completedTrackers = trackerRecordStore.completedTrackers
        categories = trackerCategoryStore.trackerCategories
        updateVisibleCategories()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        title = Constant.leftTabBarTitle
        
        [placeholderStackView, collectionView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
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
            
            //filterButton
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
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
    
    @objc
    private func datePickerTapped() {
        if filter == .todayTrackers {
            filter = .allTrackers
        }
        updateVisibleCategories()
    }
    
    @objc
    private func addButtonTapped() {
        analyticsService.report(event: .click, params: ["screen": "Main", "item": Items.add_track.rawValue])
        let vc = TrackerCreationViewController()
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    
    @objc
    private func filterButtonTapped() {
        analyticsService.report(event: .click, params: ["screen": "Main", "item": Items.filter.rawValue])
        let vc = FiltersViewController(filter)
        vc.completionHandler = { [weak self] filter in
            guard let self = self else { return }
            self.filter = filter
            self.updateVisibleCategories()
        }
        present(vc, animated: true)
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
        
        if filteredCategories.isEmpty {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
            filterButton.alpha = 1.0
        }
    }
    
    @objc
    private func updateVisibleCategories() {
        switch filter {
        case .allTrackers:
            filterAllTrackers()
        case .todayTrackers:
            filterTodayTrackers()
        case .completed:
            filterCompletedTrackers()
        case .uncompleted:
            filterCompletedTrackers()
        }
        
        visibleCategoriesForSearch = visibleCategories

        if searchController.isActive {
            searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
        } else {
            checkPlaceholderVisibility()
            collectionView.reloadData()
        }
    }
    
    private func filterAllTrackers() {
        let weekDay = Int(AppDateFormatter.shared.weekDayString(from: datePicker.date)) ?? 0
        if weekDay == 1 {
            self.weekDayString = "7"
        } else {
            self.weekDayString = String(weekDay - 1)
        }
        datePickerDateString = AppDateFormatter.shared.dateString(from: datePicker.date)
        currentDateString = AppDateFormatter.shared.dateString(from: Date())
        
        visibleCategories = []
        var trackers: [Tracker] = []
        var pinnedTrackers: [Tracker] = []
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.schedule.contains(weekDayString) || tracker.date == datePickerDateString {
                    if tracker.pinned {
                        pinnedTrackers.append(tracker)
                    } else {
                        trackers.append(tracker)
                    }
                }
            }
            
            if !trackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: trackers)
                visibleCategories.append(newCategory)
            }
            
            trackers = []
        }
        
        if !pinnedTrackers.isEmpty {
            let pinedCategory = TrackerCategory(header: Constant.trackersVCPinnedCategory, trackers: pinnedTrackers.sorted(by: { $0.name < $1.name }))
            visibleCategories.insert(pinedCategory, at: 0)
            pinnedTrackers = []
        }
        
        filteredCategories = visibleCategories
    }
    
    private func filterTodayTrackers() {
        datePicker.date = Date()
        filterAllTrackers()
    }
    
    private func filterCompletedTrackers() {
        filterAllTrackers()
        
        var completedCategory: [TrackerCategory] = []
        var uncompletedCategory: [TrackerCategory] = []
        
        var completedTrackers: [Tracker] = []
        var uncompletedTrackers: [Tracker] = []
        
        for category in visibleCategories {
            for tracker in category.trackers {
                if self.completedTrackers.contains(where: {
                    $0.id == tracker.id &&
                    $0.date == datePickerDateString }) && datePickerDateString <= currentDateString {
                    completedTrackers.append(tracker)
                } else {
                    uncompletedTrackers.append(tracker)
                }
            }
            if !completedTrackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: completedTrackers)
                completedCategory.append(newCategory)
            }
            if !uncompletedTrackers.isEmpty {
                let newCategory = TrackerCategory(header: category.header, trackers: uncompletedTrackers)
                uncompletedCategory.append(newCategory)
            }
            
            completedTrackers = []
            uncompletedTrackers = []
        }
        
        if filter == .completed {
            visibleCategories = completedCategory
        } else if filter == .uncompleted {
            visibleCategories = uncompletedCategory
        }
    }
}

extension TrackersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
            showFilter(true)
        } else if scrollView.isDragging {
            showFilter(false)
        }
    }
    
    private func showFilter(_ sender: Bool) {
        switch sender {
        case true:
            guard
                !filterButton.isHidden,
                !(filterButton.alpha == 1.0)
            else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.filterButton.alpha = 1.0
                self.filterButton.layoutIfNeeded()
            }
        case false:
            guard
                !filterButton.isHidden,
                !(filterButton.alpha == 0.0)
            else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.filterButton.alpha = 0.0
                self.filterButton.layoutIfNeeded()
            }
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        categories = trackerCategoryStore.trackerCategories
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        completedTrackers = trackerRecordStore.completedTrackers
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func updateCategories(with newTracker: Tracker, _ categoryName: String) {
        try? trackerCategoryStore.addNewTracker(newTracker, to: categoryName)
        updateVisibleCategories()
    }
    
    func changeTracker(_ tracker: Tracker, _ categoryName: String) {
        try? trackerStore.changeTracker(tracker, categoryName)
        updateVisibleCategories()
    }
    
    func setDateForNewEvent() -> String {
        return datePickerDateString
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        let newRecord = TrackerRecord(id: id, date: datePickerDateString)
        
        switch sender {
        case true:
            try? trackerRecordStore.addRecord(newRecord)
        case false:
            try? trackerRecordStore.removeRecord(newRecord)
        }
        
        updateVisibleCategories()
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]

        cell.set(tracker)
        
        if completedTrackers.contains(where: {
            $0.id == tracker.id &&
            $0.date == datePickerDateString })
        {
            cell.trackerIsCompleted(true)
        } else {
            cell.trackerIsCompleted(false)
        }

        cell.setQuantity(quantity(tracker))
        
        if datePickerDateString > currentDateString {
            cell.buttonIsEnabled(false)
        } else {
            cell.buttonIsEnabled(true)
        }
        
        cell.pinned(tracker.pinned)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = TrackerSupplementaryView.reuseIdentifier
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackerSupplementaryView else { return UICollectionReusableView() }
        
        let title = visibleCategories[indexPath.section].header
        view.setTitle(title)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = NSString(string: "\(indexPath.row):\(indexPath.section)")
        
        let pined = visibleCategories[indexPath.section].trackers[indexPath.row].pinned
        let pinTitle = pined ? Constant.trackersVCUnpin : Constant.trackersVCPin
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let pin = UIAction(title: pinTitle) { [weak self] _ in
                guard let self = self else { return }
                self.pin(indexPath)
            }
            
            let edit = UIAction(title: Constant.trackersVCEdit) { [weak self] _ in
                guard let self = self else { return }
                self.analyticsService.report(event: .click, params: ["screen": "Main", "item": Items.edit.rawValue])
                self.edit(indexPath)
            }
            
            let delete = UIAction(title: Constant.trackersVCDelete, attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.analyticsService.report(event: .click, params: ["screen": "Main", "item": Items.delete.rawValue])
                self.alert(indexPath)
            }
            
            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makePreview(collectionView, configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makePreview(collectionView, configuration)
    }
    
    private func alert(_ indexPath: IndexPath) {
        let alert = UIAlertController(
            title: Constant.trackersVCAlertTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let delete = UIAlertAction(title: Constant.trackersVCDelete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteTracker(indexPath)
        }
        
        let cancel = UIAlertAction(title: Constant.cancelButton, style: .cancel)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func makePreview(_ collectionView: UICollectionView, _ configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        let components = identifier.components(separatedBy: ":")
        guard
            let rowString = components.first,
            let sectionString = components.last,
            let row = Int(rowString),
            let section = Int(sectionString)
        else { return nil }
        let indexPath = IndexPath(row: row, section: section)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        return UITargetedPreview(view: cell.menu)
    }
    
    private func pin(_ indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        try? trackerStore.pined(tracker)
        updateVisibleCategories()
    }
    
    private func edit(_ indexPath: IndexPath) {
        var tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        guard let header = categories.first(where: { $0.trackers.contains(where: {$0.id == tracker.id}) })?.header else { return }
        
        tracker.quantity = quantity(tracker)
        
        let pickedTracker = TrackerCategory(header: header, trackers: [tracker])
        
        let trackerType: TrackerType
        if !tracker.date.isEmpty {
            trackerType = .event
        } else {
            trackerType = .habit
        }
        
        let vc = NewTrackerViewController(pickedTracker, trackerType)
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    
    private func deleteTracker(_ indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        try? trackerStore.deleteTracker(tracker)
        updateVisibleCategories()
    }
    
    private func quantity(_ tracker: Tracker) -> Int {
        var quantity = 0
        completedTrackers.forEach({
            if $0.id == tracker.id {
                quantity += 1
            }
        })
        return quantity
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
