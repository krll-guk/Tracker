import UIKit

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
