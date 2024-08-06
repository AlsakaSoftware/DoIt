import SwiftUI

struct SignUpWithEmailView: View {
    @EnvironmentObject var coordinator: AuthenticationFlowCoordinator<AuthenticationFlowRouter>
    @StateObject private var viewModel: SignUpWithEmailViewModel

    init(viewModel: SignUpWithEmailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
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
                        try await viewModel.signUp()
                        coordinator.userSignedIn()
                    } catch {
                        coordinator.showErrorAlert("Failed to create account with error: \n \(error.localizedDescription)")
                    }
                }
                
            } label: {
                Text("Create account")
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.designSystem(.primaryBackground))
        .navigationTitle("Sign up with email")
    }
}

#Preview {
    let authManger = AuthManager()
    let databaseManager = DatabaseManager()

    let viewModel = SignUpWithEmailViewModel(
        authManager: authManger,
        databaseManager: databaseManager
    )
    return SignUpWithEmailView(viewModel: viewModel)
}
