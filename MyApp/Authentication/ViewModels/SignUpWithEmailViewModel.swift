import Foundation

@MainActor
final class SignUpWithEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    private var authManager: AuthManager
    private var databaseManager: DatabaseManager

    init(authManager: AuthManager, databaseManager: DatabaseManager) {
        self.authManager = authManager
        self.databaseManager = databaseManager
    }

    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.signUpError
        }
        let authDataResult = try await authManager.createUser(email: email, password: password)
        try await databaseManager.createNewUser(auth: authDataResult)
    }
}
