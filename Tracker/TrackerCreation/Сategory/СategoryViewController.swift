import UIKit

final class CategoryViewController: UIViewController {
    
    static var category = ""
    
    private let mockData = ["Важное", "Дом", "Разное"]
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Добавить категорию", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        title = "Категория"
        
        setupAddCategoryButton()
    }
    
    private func setupAddCategoryButton() {
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategoryButtonTapped() {
        CategoryViewController.category = mockData.randomElement() ?? ""
        print(CategoryViewController.category)
        
        navigationController?.popViewController(animated: true)
    }
}
