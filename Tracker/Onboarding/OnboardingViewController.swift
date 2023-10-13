import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = {
        return [blueViewController, redViewController]
    }()
    
    private lazy var blueViewController: UIViewController = {
        let vc = UIViewController()
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = Image.backgroundBlue
        imageView.center = view.center
        vc.view.addSubview(imageView)
        vc.view.addSubview(labelBlue)
        vc.view.sendSubviewToBack(imageView)
        vc.overrideUserInterfaceStyle = .light
        return vc
    }()
    
    private lazy var redViewController: UIViewController = {
        let vc = UIViewController()
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = Image.backgroundRed
        imageView.center = view.center
        vc.view.addSubview(imageView)
        vc.view.addSubview(labelRed)
        vc.view.sendSubviewToBack(imageView)
        vc.overrideUserInterfaceStyle = .light
        return vc
    }()
    
    private lazy var labelBlue: UILabel = {
        let label = UILabel()
        label.font = Font.bold32
        label.textColor = Color.black
        label.text = Constant.onboardingLabelBlue
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelRed: UILabel = {
        let label = UILabel()
        label.font = Font.bold32
        label.textColor = Color.black
        label.text = Constant.onboardingLabelRed
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = Color.black
        pageControl.pageIndicatorTintColor = Color.black?.withAlphaComponent(0.3)
        return pageControl
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = Font.medium16
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle(Constant.onboardingButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupView()
    }
    
    private func setupView() {
        view.overrideUserInterfaceStyle = .light
        [pageControl, enterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // enterButton
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterButton.heightAnchor.constraint(equalToConstant: 60),
            
            // pageControl
            pageControl.bottomAnchor.constraint(equalTo: enterButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // labelBlue
            labelBlue.bottomAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            labelBlue.leadingAnchor.constraint(equalTo: blueViewController.view.leadingAnchor, constant: 16),
            labelBlue.trailingAnchor.constraint(equalTo: blueViewController.view.trailingAnchor, constant: -16),
            
            // labelRed
            labelRed.bottomAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            labelRed.leadingAnchor.constraint(equalTo: redViewController.view.leadingAnchor, constant: 16),
            labelRed.trailingAnchor.constraint(equalTo: redViewController.view.trailingAnchor, constant: -16),
        ])
    }
    
    @objc
    private func enterButtonTapped() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarController()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
