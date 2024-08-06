import SwiftUI
import AuthenticationServices

struct AuthenticationOptionsView: View {
    @EnvironmentObject var coordinator: AuthenticationFlowCoordinator<AuthenticationFlowRouter>
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var viewModel: AuthenticationOptionsViewModel
    
    init(viewModel: AuthenticationOptionsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    Image("logo_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .foregroundStyle(Color.designSystem(.primaryControlBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 10)
                    
                    Text("The only friend you need this weekend")
                        .multilineTextAlignment(.center)
                        .font(.designSystem(.heading1))
                        .padding(.bottom, 30)

                    signInButton
                        .padding(.bottom, 3)
                    signUpButton
                    
                    Text("or")
                        .font(.designSystem(.button2))
                        .padding(.vertical, 10)
                    
                    signInWithAppleButton
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.designSystem(.primaryBackground))
            .onChange(of: viewModel.didSignInWithAppleSuccessfully) { _, success in
                if success {
                    coordinator.userSignedIn()
                }
            }
            .onChange(of: viewModel.appleSignInError) { _, error in
                guard let error else { return }
                                
                coordinator.showErrorAlert("Failed to sign in with error: \n \(error.localizedDescription)")
            }
    }
    
    var signInWithAppleButton: some View {
        Button {
            viewModel.startSignInWithAppleFlow(presentationAnchor: coordinator.navigationController.topViewController?.view.window)
        } label: {
            AppleButtonView(type: .continue, style: .black)
                .allowsHitTesting(false)
                .frame(height: 55)
        }
    }
    
    var signInButton: some View {
        PrimaryButton {
            coordinator.show(.signInWithEmail(authManager: viewModel.authManager, databaseManager: viewModel.databaseManager))

        } label: {
            Text("Sign In with Email")
        }
    }
    
    var signUpButton: some View {
        PrimaryButton {
            coordinator.show(.signUpWithEmail(authManager: viewModel.authManager, databaseManager: viewModel.databaseManager))

        } label: {
            Text("Sign Up with Email")
        }
    }
}

#Preview {
    let authManager = AuthManager()
    let databaseManager = DatabaseManager()
    
    let viewModel = AuthenticationOptionsViewModel(
        authManager: authManager,
        databaseManager: databaseManager
    )

    return AuthenticationOptionsView(viewModel: viewModel)
}

struct AppleButtonView: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let authorization = ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        return authorization
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
