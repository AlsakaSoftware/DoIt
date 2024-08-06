import Foundation
import SwiftUI
import FirebaseAuth

class AppCoordinator<Router: NavigationRouter>: Coordinator<AppRouter> {
    private let authManager: AuthManager
    private let databaseManager: DatabaseManager
    
    override init(navigationController: UINavigationController = .init(), startingRoute: AppRouter? = nil) {
        self.authManager = AuthManager()
        self.databaseManager = DatabaseManager()
        super.init(navigationController: navigationController, startingRoute: startingRoute)
    }
    
    public override func start() {
        if authManager.isUserSignedIn() {
            Task {
                await PurchasesManager.shared.getSubscriptionStatus()
            }
            showMainAppFlow()
        } else {
            showLoginFlow()
        }
    }
    
    func showLoginFlow() {
        navigationController.setViewControllers([], animated: false)
        let coordinator = AuthenticationFlowCoordinator<AuthenticationFlowRouter>(
            navigationController: navigationController,
            appCoordinator: self,
            authManager: authManager,
            databaseManager: databaseManager
        )
        coordinator.start()
    }
    
    func showMainAppFlow() {
        navigationController.setViewControllers([], animated: false)
        let coordinator = TabBarCoordinator<TabBarRouter>(
            navigationController: navigationController,
            appCoordinator: self,
            authManager: authManager,
            databaseManager: databaseManager
        )
        coordinator.start()
    }
}
