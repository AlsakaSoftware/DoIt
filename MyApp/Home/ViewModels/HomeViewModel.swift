import Foundation

final class HomeViewModel: ObservableObject {
    private let authManager: AuthManager
    private let databaseManager: DatabaseManager
    var listDate: Date = Date()
    
    @Published var todaysList = ToDoList(items: [])

    init(authManager: AuthManager, databaseManager: DatabaseManager) {
        self.authManager = authManager
        self.databaseManager = databaseManager
     
        loadToDoItems()
    }

    func updateCompletionStatus(item: ToDoItem) {
        guard let userId = authManager.signedInUserId(), let index = todaysList.items.firstIndex(where: { $0.id == item.id }) else { return }
            
        todaysList.items[index].isCompleted.toggle()
        
        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: listDate)
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
                self.todaysList = list
            }
        }
    }
    
    func addToDoItem(item: ToDoItem) {
        guard let userId = authManager.signedInUserId() else { return }
        todaysList.items.append(item)
        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: listDate)
        } catch let error {
            print("failed to add todo item to list with error \(error)")
        }
        loadToDoItems()
    }
    
    @MainActor
    func deleteItem(itemId: UUID) async {
        guard let userId = authManager.signedInUserId(), let index = todaysList.items.firstIndex(where: { $0.id == itemId }) else { return }
        todaysList.items.remove(at: index)

        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: listDate)
        } catch let error {
            print("couldn't delete due to error \(error)")
        }
    }
}
