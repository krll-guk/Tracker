import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = Color.blue
        tabBar.unselectedItemTintColor = Color.gray
        tabBar.backgroundColor = Color.white
        
        let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
        trackersViewController.tabBarItem = UITabBarItem(
            title: Constant.leftTabBarTitle,
            image: Image.tabBarLeft,
            selectedImage: nil
        )
        
        let statisticsViewController = UINavigationController(rootViewController: StatisticsViewController())
        statisticsViewController.tabBarItem = UITabBarItem(
            title: Constant.rightTabBarTitle,
            image: Image.tabBarRight,
            selectedImage: nil
        )
        
        viewControllers = [trackersViewController, statisticsViewController]
    }
}
