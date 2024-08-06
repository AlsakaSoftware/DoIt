import SwiftUI

struct SignInWithEmailView: View {
    @EnvironmentObject var coordinator: AuthenticationFlowCoordinator<AuthenticationFlowRouter>
    @StateObject private var viewModel: SignInWithEmailViewModel

    init(viewModel: SignInWithEmailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.designSystem(.secondaryBackground).opacity(0.5))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.designSystem(.secondaryBackground).opacity(0.5))
                .cornerRadius(10)
            
            PrimaryButton {
                Task {
                    do {
                        try await viewModel.signIn()
                        coordinator.userSignedIn()
                    } catch {
                        coordinator.showErrorAlert("Failed to sign in with error: \n \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Sign In")
            }
            .padding(.top, 10)
            .padding(.bottom, 20)

            Text("Forgot password?")
                .padding(.bottom, 5)
            
            SecondaryButton {
                coordinator.show(.resetPassword(authManager: viewModel.authManager))
            } label: {
                Text("Reset my password")
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.designSystem(.primaryBackground))
        .navigationTitle("Sign in with email")
    }
}

#Preview {
    let authManger = AuthManager()
    let databaseManager = DatabaseManager()

    let viewModel = SignInWithEmailViewModel(
        authManager: authManger,
        databaseManager: databaseManager
    )
    return SignInWithEmailView(viewModel: viewModel)
}
