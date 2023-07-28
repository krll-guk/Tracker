import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let trackerCategoryStore = TrackerCategoryStore()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        
        if trackerCategoryStore.isEmpty {
            window.rootViewController = OnboardingViewController(transitionStyle: .scroll,
                                                                 navigationOrientation: .horizontal)
        } else {
            window.rootViewController = TabBarController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
