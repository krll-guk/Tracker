import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let viewController = ViewController()
//        let navigationController = UINavigationController(rootViewController: viewController)
//        window.rootViewController = navigationController
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }
}
