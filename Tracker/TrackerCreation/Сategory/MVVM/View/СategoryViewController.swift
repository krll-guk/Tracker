import UIKit

final class CategoryViewController: UIViewController {
    
    var completionHandler: ((String) -> Void)?
    
    private var viewModel: CategoryViewModel!
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.categoryVCTitle
        return label
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
        label.text = Constant.categoryVCPlaceholder
        label.numberOfLines = 0
        label.addInterlineSpacing(spacingValue: 18 - label.font.lineHeight)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.categoryVCButton, for: .normal)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = Color.gray
        tableView.isScrollEnabled = true
        tableView.allowsMultipleSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.categoryVCReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CategoryViewModel()
        checkPlaceholderVisibility()
        
        if let selectedCategory = UserDefaults.standard.string(forKey: "selectedCategory") {
            viewModel.selected(categoryName: selectedCategory)
        }
        
        viewModel.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            self.checkPlaceholderVisibility()
            self.tableView.reloadData()
        }
        
        viewModel.$selectedCategory.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        
        [viewNameLabel, placeholderStackView, addCategoryButton, tableView].forEach {
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
            
            // stackView
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            // addCategoryButton
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: viewNameLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
        ])
    }
    
    private func checkPlaceholderVisibility() {
        placeholderStackView.isHidden = viewModel.categories.isEmpty ? false : true
        tableView.isHidden = viewModel.categories.isEmpty ? true : false
    }
    
    @objc
    private func addCategoryButtonTapped() {
        let vc = NewCategoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constant.categoryVCReuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = viewModel.categories[indexPath.row].categoryName
        cell.textLabel?.font = Font.regular17
        cell.textLabel?.textColor = Color.black
        cell.selectionStyle = .none
        cell.backgroundColor = Color.background
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 16
        
        if viewModel.categories.count == 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner,
                                        .layerMinXMinYCorner,.layerMaxXMinYCorner]
            cell.separatorInset.right = tableView.bounds.width
        }
        
        if viewModel.categories.count > 1 {
            switch indexPath.row {
            case 0:
                cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            case viewModel.categories.count - 1:
                cell.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
                cell.separatorInset.right = tableView.bounds.width
            default:
                cell.layer.cornerRadius = 0
            }
        }
        
        if viewModel.selectedCategory?.categoryName == viewModel.categories[indexPath.row].categoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selected = cell.textLabel?.text else { return }
        viewModel.selected(categoryName: selected)
        completionHandler?(selected)
        navigationController?.popViewController(animated: true)
    }
}
