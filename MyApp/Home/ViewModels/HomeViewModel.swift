import Foundation

final class HomeViewModel: ObservableObject {
    private let authManager: AuthManager
    private let userManager: UserManager

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
    func updateCompletionStatus(for itemId: UUID, to: Bool) {
        
    }

    private func loadToDoItems() {
        
    }
}
