import SwiftUI
import RevenueCat

@main
struct MyAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        /// Input your revenue cat api key
        Purchases.configure(withAPIKey: "appl_qtHpVUsFnvarJzcXiNXRrWQZjDb")
    }

    var body: some Scene {
        WindowGroup {
            NavigationController()
                .ignoresSafeArea()
        }
    }
}

struct NavigationController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator<AppRouter>(navigationController: navigationController)
        
        coordinator.start()
        return coordinator.navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed for now
    }
}
