import UIKit

final class ScheduleViewController: UIViewController {
    
    var completionHandler: (([String: String]) -> Void)?
    
    private let titles = Constant.scheduleVCTableTitles
    private var selectedSchedule = [String: String]()
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.scheduleVCTitle
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = Color.gray
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.scheduleVCReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.scheduleVCButton, for: .normal)
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(_ selectedSchedule: [String: String]) {
        self.selectedSchedule = selectedSchedule
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
        
        [viewNameLabel, tableView, readyButton].forEach {
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
            tableView.heightAnchor.constraint(equalToConstant: 524.5),
            
            // readyButton
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc
    private func readyButtonTapped() {
        completionHandler?(selectedSchedule)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constant.scheduleVCReuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = titles[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = Color.background
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        addSwitchView(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func addSwitchView(cell: UITableViewCell, indexPath: IndexPath) {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = Color.blue
        switchView.setOn(false, animated: false)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
        cell.accessoryView = switchView
        
        for (index, _) in selectedSchedule {
            let intIndex = Int(index) ?? 0
            if switchView.tag == intIndex - 1 {
                switchView.setOn(true, animated: false)
            }
        }
    }
    
    @objc
    private func switchChanged(_ sender: UISwitch!) {
        for (index, weekday) in Constant.weekDays {
            let intIndex = Int(index) ?? 0
            if sender.tag == intIndex - 1 {
                if sender.isOn {
                    selectedSchedule.updateValue(weekday, forKey: index)
                } else {
                    selectedSchedule.removeValue(forKey: index)
                }
            }
        }
    }
}
