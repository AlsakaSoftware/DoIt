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

final class UserManager {
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

extension UserManager: Equatable {
    static func == (lhs: UserManager, rhs: UserManager) -> Bool {
        
        // UserManager doesn't have any meaningful properties
        // to compare, you we can just return true
        return true
    }
}

// MARK: UserManager + ToDoItem
extension UserManager {
    func addToDoItem(item: ToDoItem, userId: String, forDate: Date) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: forDate)
        
        guard dateString != "" else {
            // temporary error
            throw AuthError.signInError
        }
        
        let docRef = database.collection("users").document(userId).collection("lists").document(dateString).collection("items").document(item.id.uuidString)

        do {
            try docRef.setData(from: item, merge: true)
        } catch let error {
            print("Error writing ToDoItem to Firestore: \(error)")
        }
    }

    func updateToDoItem(item: ToDoItem, userId: String, forDate: Date) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: forDate)
        
        guard dateString != "" else {
            // temporary error
            throw AuthError.signInError
        }
        
        let docRef = database.collection("users").document(userId).collection("lists").document(dateString).collection("items").document(item.id.uuidString)

        do {
            try docRef.setData(from: item, merge: true)
        } catch let error {
            print("Error writing ToDoItem to Firestore: \(error)")
        }

    }

    func fetchList(userId: String, date: Date) async throws -> [ToDoItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userId).collection("lists").document(dateString).collection("items")
        
        let querySnapshot = try await collectionRef.getDocuments()

        var toDoItems = [ToDoItem]()
        for document in querySnapshot.documents {
            if let toDoItem = try? document.data(as: ToDoItem.self) {
                toDoItems.append(toDoItem)
            }
        }
        
        return toDoItems
    }
    
    func deleteToDoItem(userId: String, listDate: Date, itemId: UUID) async throws{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: listDate)

        let docRef = database.collection("users").document(userId).collection("lists").document(dateString).collection("items").document(itemId.uuidString)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            docRef.delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
