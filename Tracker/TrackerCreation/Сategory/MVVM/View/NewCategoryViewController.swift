import UIKit

final class NewCategoryViewController: UIViewController {
    
    private var viewModel: CategoryViewModel!

    private var newCategory: CategoryModel?
    
    private lazy var viewNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium16
        label.textColor = Color.black
        label.text = Constant.newCategoryVCTitle
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(errorLabel)
        return stack
    }()
    
    private lazy var textField: UITextField = {
        let textField = CustomTextField(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41))
        textField.backgroundColor = Color.background
        textField.layer.cornerRadius = 16
        textField.font = Font.regular17
        textField.textColor = Color.black
        textField.attributedPlaceholder = NSAttributedString(
            string: Constant.newCategoryVCTextFieldPlaceholder,
            attributes: [
                .foregroundColor: Color.gray ?? .systemGray,
                .font: Font.regular17,
            ]
        )
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .default
        textField.returnKeyType = .go
        textField.delegate = self
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular17
        label.textColor = Color.red
        label.isHidden = true
        label.alpha = 0.0
        label.text = Constant.newCategoryVCErrorLabel
        return label
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.gray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.newCategoryVCButton, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CategoryViewModel()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = Color.white
        
        [viewNameLabel, stackView, readyButton].forEach {
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
            
            // addCategoryButton
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            
            // stackView
            stackView.topAnchor.constraint(equalTo: viewNameLabel.bottomAnchor, constant: 38),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // textField
            textField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // errorLabel
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    @objc
    private func readyButtonTapped() {
        guard let newCategory = self.newCategory else { return }
        viewModel.addNewCategory(newCategory)
        navigationController?.popViewController(animated: true)
    }
    
    private func activateCreateButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
            self.readyButton.isEnabled = true
            self.readyButton.backgroundColor = Color.black
        }
    }
    
    private func deactivateCreateButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) {
            self.readyButton.isEnabled = false
            self.readyButton.backgroundColor = Color.gray
        }
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        for category in viewModel.categories {
            if category.categoryName.lowercased() == newString.lowercased() {
                showError()
                return true
            } else {
                hideError()
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        deactivateCreateButton()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        newCategory = nil
        hideError()
        deactivateCreateButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if errorLabel.isHidden != true || textField.text == "" {
            return false
        }
        textField.resignFirstResponder()
        newCategory = CategoryModel(categoryName: textField.text ?? "")
        activateCreateButton()
        return true
    }
}

extension NewCategoryViewController {
    private func showError() {
        guard errorLabel.isHidden else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.errorLabel.alpha = 1.0
            self.errorLabel.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func hideError() {
        guard !errorLabel.isHidden else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.errorLabel.alpha = 0.0
            self.errorLabel.isHidden = true
            self.stackView.layoutIfNeeded()
        }
    }
}
