import UIKit

final class ScheduleViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let titles = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedSchedule = [Int: String]()
    
    static var schedule = [String]()
    static var scheduleForTable = ""
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Готово", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        title = "Расписание"
        
        setupTableView()
        setupReadyButton()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 524)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupReadyButton() {
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func readyButtonTapped() {
        let sorted = selectedSchedule.sorted { $0.key < $1.key }
        let valuesArraySorted = Array(sorted.map({ $0.value }))
        
        ScheduleViewController.schedule = valuesArraySorted
        ScheduleViewController.scheduleForTable = valuesArraySorted.joined(separator:", ")
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "Background")
        
        addSwitchView(cell: cell, indexPath: indexPath)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func addSwitchView(cell: UITableViewCell, indexPath: IndexPath) {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .systemBlue
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
        cell.accessoryView = switchView
    }
    
    @objc
    private func switchChanged(_ sender: UISwitch!) {
        for (index, weekday) in WeekDay.allCases.enumerated() {
            if sender.tag == index {
                if sender.isOn {
                    selectedSchedule.updateValue(weekday.rawValue, forKey: index)
                } else {
                    selectedSchedule.removeValue(forKey: index)
                }
            }
        }
    }
}
