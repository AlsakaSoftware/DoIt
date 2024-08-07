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
        let dateString = forDate.listDateStringFormat()

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

    func doesListExist(userId: String, date: Date) async throws -> Bool {
        let dateString = date.listDateStringFormat()

        let db = Firestore.firestore()
        let listDocRef = db.collection("users").document(userId).collection("lists").document(dateString)
        
        return try await listDocRef.getDocument().exists
    }
    
    func fetchList(userId: String, date: Date) async throws -> ToDoList {
        let dateString = date.listDateStringFormat()

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

    func fetchListsBeforeOrOnDate(userId: String, fromDate: Date) async throws -> [ToDoList] {
        guard let dateString = fromDate.dayAfter()?.listDateStringFormat() else {
            print("issue with getting required date string")
            return []
        }
        
        let db = Firestore.firestore()
        let listsCollectionRef = db.collection("users").document(userId).collection("lists")
        
        // Perform the query
        let querySnapshot = try await listsCollectionRef.whereField(FieldPath.documentID(), isLessThanOrEqualTo: dateString).getDocuments()
        
        var lists = [ToDoList]()
        for document in querySnapshot.documents {
            if let list = try? document.data(as: ToDoList.self) {
                lists.append(list)
            }
        }

        return lists
    }
}

extension Date {
    func listDateStringFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func dayAfter() -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func dayBefore() -> Date? {
        Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func titleFormat() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return dateStringDisplayFormat()
        }
    }
    
    func dateStringDisplayFormat() -> String {
        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: self)

        let dateFormatter = DateFormatter()
        
        if currentYear == dateYear {
            dateFormatter.dateFormat = "dd MMM"
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
        }

        return dateFormatter.string(from: self)
    }
}
