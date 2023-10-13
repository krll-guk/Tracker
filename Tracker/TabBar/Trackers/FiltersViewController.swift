import UIKit

final class FiltersViewController: UIViewController {
    
    var completionHandler: ((Filter) -> Void)?
    
    private let reuseIdentifier = "FilterTableViewCell"
    
    private let titles = Constant.filtersVCTableTitles
    
    private var selectedFilter = Filter.allTrackers
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.filtersVCTitle
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = Color.gray
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(_ filter: Filter) {
        self.selectedFilter = filter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        
        [viewNameLabel, tableView].forEach {
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
            
            // tableView
            tableView.topAnchor.constraint(equalTo: viewNameLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 299.5),
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = titles[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = Color.background
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryType = .none
        
        switch indexPath.row {
        case 0:
            if selectedFilter == .allTrackers {
                cell.accessoryType = .checkmark
            }
        case 1:
            if selectedFilter == .todayTrackers {
                cell.accessoryType = .checkmark
            }
        case 2:
            if selectedFilter == .completed {
                cell.accessoryType = .checkmark
            }
        case 3:
            if selectedFilter == .uncompleted {
                cell.accessoryType = .checkmark
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            selectedFilter = .allTrackers
        case 1:
            selectedFilter = .todayTrackers
        case 2:
            selectedFilter = .completed
        case 3:
            selectedFilter = .uncompleted
        default:
            break
        }
        
        completionHandler?(selectedFilter)
        dismiss(animated: true)
    }
}
