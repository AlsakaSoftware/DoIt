import SwiftUI

enum HomeFlowRouter: NavigationRouter, Equatable {
    case home(authManager: AuthManager, userManager: UserManager)
    case paywall
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .paywall:
            return "Paywall"

        }
    }

    var transition: NavigationTranisitionStyle {
        switch self {
        case .home:
            return .push
        case .paywall:
            return .presentModally
        }
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        switch self {
        case .home(let authManager, let userManager):
            let viewModel = HomeViewModel(authManager: authManager, userManager: userManager)
            HomeView(viewModel: viewModel)
        case .paywall:
            PaywallView()
        }
    }
}
