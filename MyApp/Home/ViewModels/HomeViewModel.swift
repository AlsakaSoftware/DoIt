import Foundation

final class HomeViewModel: ObservableObject {
    private let authManager: AuthManager
    private let userManager: UserManager
    var listDate: Date = Date()
    
    
    @Published var toDoItems: [ToDoItem] = [
        ToDoItem(id: UUID(), dayIndex: 1, title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), dayIndex: 1, title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), dayIndex: 1, title: "Task 1", description: "Task 1 description", isMainTask: false, isCompleted: true),
        ToDoItem(id: UUID(), dayIndex: 1, title: "Task 1", description: "Task 1 description", isMainTask: false, isCompleted: false)
    ]
    

    init(authManager: AuthManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
     
        loadToDoItems()
    }

    func updateCompletionStatus(item: ToDoItem) {
        guard let userId = authManager.signedInUserId(), let index = toDoItems.firstIndex(where: { $0.id == item.id }) else { return }
            
        toDoItems[index].isCompleted.toggle()
        
        do {
            try userManager.updateToDoItem(item: toDoItems[index], userId: userId, forDate: listDate)
            loadToDoItems()
        } catch let error {
            print("failed to update item with \(error)")
        }
    }

    private func loadToDoItems() {
        Task {
            guard let userId = authManager.signedInUserId() else { return }
            let toDoItems = try await userManager.fetchList(userId: userId, date: listDate)
            DispatchQueue.main.async {
                self.toDoItems = toDoItems
            }
        }
    }
    
    func addToDoItem(item: ToDoItem) {
        guard let userId = authManager.signedInUserId() else { return }
        
        do {
            try userManager.addToDoItem(item: item, userId: userId, forDate: listDate)
            loadToDoItems()
        } catch let error {
            print("failed to add todo item to list with error \(error)")
        }
    }
}
