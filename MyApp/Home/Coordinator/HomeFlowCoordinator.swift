import Foundation
import SwiftUI

class HomeFlowCoordinator<Router: NavigationRouter>: Coordinator<HomeFlowRouter> {
    private var tabbarCoordinator: TabBarCoordinator<TabBarRouter>?
    private var authManager: AuthManager
    private var databaseManager: DatabaseManager

    init(
        navigationController: UINavigationController = .init(),
        startingRoute: HomeFlowRouter? = nil,
        tabbarCoordinator: Coordinator<TabBarRouter>? = nil,
        authManager: AuthManager,
        databaseManager: DatabaseManager
    ) {
        self.tabbarCoordinator = tabbarCoordinator as? TabBarCoordinator<TabBarRouter>
        self.authManager = authManager
        self.databaseManager = databaseManager
        super.init(navigationController: navigationController, startingRoute: startingRoute)
    }

    // Override the base Coordinator's show() function because the environmentObject needs to be of type HomeCoordinator and not BaseCoordinator
    public override func show(_ route: HomeFlowRouter, hideTabBar: Bool = false, hideNavBar: Bool = false, animated: Bool = true, environmentObjects: [any ObservableObject] = []) {
        var environmentObjects: [any ObservableObject] = environmentObjects
        environmentObjects.append(self)
        super.show(route, hideTabBar: hideTabBar, animated: animated, environmentObjects: environmentObjects)
    }
}
