import SwiftUI

enum HomeFlowRouter: NavigationRouter, Equatable {
    static func == (lhs: HomeFlowRouter, rhs: HomeFlowRouter) -> Bool {
        switch (lhs, rhs) {
        case (.addItem(let onAddItem1), .addItem(let onAddItem2)):
            return onAddItem1 == nil && onAddItem2 == nil
        default:
            return true
        }
    }

    case home(authManager: AuthManager, databaseManager: DatabaseManager)
    case addItem(onAddItem: ((ToDoItem) -> Void)? = nil)
    case paywall
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .addItem:
            return "Add item"
        case .paywall:
            return "Paywall"

        }
    }

    var transition: NavigationTranisitionStyle {
        switch self {
        case .home:
            return .push
        case .addItem:
            return .presentModally
        case .paywall:
            return .presentModally
        }
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        switch self {
        case .home(let authManager, let databaseManager):
            let viewModel = HomeViewModel(authManager: authManager, databaseManager: databaseManager)
            HomeView(viewModel: viewModel)
        case .addItem(let onAddItem):
            AddItemView(onAddItem: onAddItem)
        case .paywall:
            PaywallView()
        }
    }
}
