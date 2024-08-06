import Foundation
import SwiftUI

class SettingsFlowCoordinator<Router: NavigationRouter>: Coordinator<SettingsFlowRouter> {
    private var tabbarCoordinator: TabBarCoordinator<TabBarRouter>?
    private var authManager: AuthManager
    private var databaseManager: DatabaseManager

    init(
        navigationController: UINavigationController = .init(),
        startingRoute: SettingsFlowRouter? = nil,
        tabbarCoordinator: Coordinator<TabBarRouter>? = nil,
        authManager: AuthManager,
        databaseManager: DatabaseManager
    ) {
        self.authManager = authManager
        self.databaseManager = databaseManager
        self.tabbarCoordinator = tabbarCoordinator as? TabBarCoordinator<TabBarRouter>
        super.init(navigationController: navigationController, startingRoute: startingRoute)
    }
    
    // Override the base Coordinator's show() function because the environmentObject needs to be of type SettingsFlowCoordinator and not BaseCoordinator
    override func show(_ route: SettingsFlowRouter, hideTabBar: Bool = false, hideNavBar: Bool = false, animated: Bool = true, environmentObjects: [any ObservableObject] = []) {
        var environmentObjects: [any ObservableObject] = environmentObjects
        environmentObjects.append(self)
        super.show(route, hideTabBar: hideTabBar, animated: animated, environmentObjects: environmentObjects)
    }
    
    func userSignedOut() {
        tabbarCoordinator?.goToAuthenticationFlow()
    }
}
