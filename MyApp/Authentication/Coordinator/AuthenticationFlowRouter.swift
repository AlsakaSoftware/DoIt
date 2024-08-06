import SwiftUI

enum AuthenticationFlowRouter: NavigationRouter {
    case authenticationOptionsView(authManager: AuthManager, databaseManager: DatabaseManager)
    case signInWithEmail(authManager: AuthManager, databaseManager: DatabaseManager)
    case signUpWithEmail(authManager: AuthManager, databaseManager: DatabaseManager)
    case resetPassword(authManager: AuthManager)
    
    var transition: NavigationTranisitionStyle {
        .push
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        switch self {
        case .authenticationOptionsView(let authManager, let databaseManager):
            let viewModel = AuthenticationOptionsViewModel(authManager: authManager, databaseManager: databaseManager)
            AuthenticationOptionsView(viewModel: viewModel)

        case .signInWithEmail(let authManager, let databaseManager):
            let viewModel = SignInWithEmailViewModel(
                authManager: authManager,
                databaseManager: databaseManager
            )
            SignInWithEmailView(viewModel: viewModel)

        case .signUpWithEmail(let authManager, let databaseManager):
            let viewModel = SignUpWithEmailViewModel(
                authManager: authManager,
                databaseManager: databaseManager
            )
            SignUpWithEmailView(viewModel: viewModel)

        case .resetPassword(let authManager):
            let viewModel = ResetPasswordViewModel(authManager: authManager)
            ResetPasswordView(viewModel: viewModel)
        }
    }
}
