import Foundation

struct ToDoItem: Codable, Identifiable {
    var id: UUID
    var dayIndex: Int
    var title: String
    var description: String
    var isMainTask: Bool
    var isCompleted: Bool
}

struct ToDoList: Codable {
    var dateString: String
    var items: [ToDoItem]
}
