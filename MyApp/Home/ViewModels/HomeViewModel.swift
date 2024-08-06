import Foundation

final class HomeViewModel: ObservableObject {
    private let authManager: AuthManager
    private let databaseManager: DatabaseManager
    var listDate: Date = Date()
    
    
    @Published var list = ToDoList(items: [])

    init(authManager: AuthManager, databaseManager: DatabaseManager) {
        self.authManager = authManager
        self.databaseManager = databaseManager
     
        loadToDoItems()
    }

    func updateCompletionStatus(item: ToDoItem) {
        guard let userId = authManager.signedInUserId(), let index = list.items.firstIndex(where: { $0.id == item.id }) else { return }
            
        list.items[index].isCompleted.toggle()
        
        do {
            try databaseManager.updateList(list: list, userId: userId, forDate: listDate)
        } catch let error {
            print("failed to update item with \(error)")
        }
        loadToDoItems()
    }

    private func loadToDoItems() {
        Task {
            guard let userId = authManager.signedInUserId() else { return }
            let list = try await databaseManager.fetchList(userId: userId, date: listDate)
            DispatchQueue.main.async {
                self.list = list
            }
        }
    }
    
    func addToDoItem(item: ToDoItem) {
        guard let userId = authManager.signedInUserId() else { return }
        list.items.append(item)
        do {
            try databaseManager.updateList(list: list, userId: userId, forDate: listDate)
        } catch let error {
            print("failed to add todo item to list with error \(error)")
        }
        loadToDoItems()
    }
    
    @MainActor
    func deleteItem(itemId: UUID) async {
        guard let userId = authManager.signedInUserId(), let index = list.items.firstIndex(where: { $0.id == itemId }) else { return }
        list.items.remove(at: index)

        do {
            try databaseManager.updateList(list: list, userId: userId, forDate: listDate)
        } catch let error {
            print("couldn't delete due to error \(error)")
        }
    }
}
