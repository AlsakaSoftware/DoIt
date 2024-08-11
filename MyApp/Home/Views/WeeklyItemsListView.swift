import SwiftUI

struct WeeklyItemsListView: View {
    @State private var isShowingWeeklyItems = false

    var items: [ToDoItem]

    init(items: [ToDoItem]) {
        self.items = items
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, alignment: .trailing) {
                ForEach(items) { item in
                    toDoItemRow(item: item)
                }
            }
                .padding(10)
        }
    }
    
    // MARK: ViewBuilder functions
    @ViewBuilder
    func toDoItemRow(item: ToDoItem) -> some View {
        HStack {
            Text(item.title)
                .padding(.horizontal, 5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 100)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)

        .background(Color.designSystem(.secondaryBackground).opacity(0.5))
        .cornerRadius(10)
//        .onDrag {
//            self.draggedItem = item
//            return NSItemProvider()
//        }
//        .onDrop(of: [.toDoItem],
//                delegate: ToDoListDropViewDelegate(destinationItem: item, items: $viewModel.todaysList.items, draggedItem: $draggedItem)
//        )
    }
}

#Preview {
    WeeklyItemsListView(items: [
        ToDoItem(id: UUID(), title: "Go on a sunrise hike", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Read 30 minutes", description: "Task 2 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), title: "Yoga session after work ", description: "Task 3 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 2asdsa", description: "Task 2 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), title: "Task 3", description: "Task 3 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task sadasad", description: "Task 2 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), title: "asdad", description: "Task 3 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 2", description: "Task 2 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), title: "Task 3", description: "Task 3 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 1", description: "Task 1 description", isMainTask: true, isCompleted: true),
        ToDoItem(id: UUID(), title: "Task 2", description: "Task 2 description", isMainTask: true, isCompleted: false),
        ToDoItem(id: UUID(), title: "Task 3", description: "Task 3 description", isMainTask: true, isCompleted: true)
    ])
}
