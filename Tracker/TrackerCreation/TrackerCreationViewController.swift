import UIKit

final class TrackerCreationViewController: UIViewController {
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Нерегулярные событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        title = "Создание трекера"
        setupHabitButton()
        setupIrregularEventButton()
    }
    
    private func setupHabitButton() {
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        NSLayoutConstraint.activate([
            habitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -8),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupIrregularEventButton() {
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            irregularEventButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 8),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        navigationController?.pushViewController(NewHabitViewController(), animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        navigationController?.pushViewController(NewIrregularEventViewController(), animated: true)
    }
}
