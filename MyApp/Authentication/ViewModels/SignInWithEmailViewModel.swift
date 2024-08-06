import Foundation

@MainActor
final class SignInWithEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    var authManager: AuthManager
    private var databaseManager: DatabaseManager

    init(authManager: AuthManager, databaseManager: DatabaseManager) {
        self.authManager = authManager
        self.databaseManager = databaseManager
    }

    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.signInError
        }
        
        try await authManager.signIn(email: email, password: password)
    }
}
