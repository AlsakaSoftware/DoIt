import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser {
    var userId: String
    var email: String?
    var date_created: Date?
}

enum DBError: Error {
    case connectionError
}

final class DatabaseManager {
    let database = Firestore.firestore()
    
    func createNewUser(auth: AuthUserModel) async throws {
        var userData: [String : Any] = [
            "user_id" : auth.id,
            "date_created": Timestamp()
        ]

        if let email = auth.email {
            userData["email"] = email
        }
        
        try await database.collection("users").document(auth.id).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser  {
        let snapshot = try await database.collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw DBError.connectionError
        }
        

        let email = data["email"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DBUser(userId: userId, email: email, date_created: dateCreated)
    }
}

extension DatabaseManager: Equatable {
    static func == (lhs: DatabaseManager, rhs: DatabaseManager) -> Bool {
        
        // databaseManager doesn't have any meaningful properties
        // to compare, you we can just return true
        return true
    }
}

// MARK: databaseManager + ToDoItem
extension DatabaseManager {
    func updateList(list: ToDoList, userId: String, forDate: Date) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: forDate)
        
        guard dateString != "" else {
            // temporary error
            throw AuthError.signInError
        }
        
        let docRef = database.collection("users").document(userId).collection("lists").document(dateString)

        do {
            try docRef.setData(from: list, merge: true)
        } catch let error {
            print("Error writing ToDoItem to Firestore: \(error)")
        }

    }

    func fetchList(userId: String, date: Date) async throws -> ToDoList {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let db = Firestore.firestore()
        let listDocRef = db.collection("users").document(userId).collection("lists").document(dateString)
        
        let documentSnapshot = try await listDocRef.getDocument()

        guard documentSnapshot.exists else {
            print("Document does not exist at path: \(listDocRef.path)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
        }
        
        let list = try documentSnapshot.data(as: ToDoList.self)
        return list
    }
}
