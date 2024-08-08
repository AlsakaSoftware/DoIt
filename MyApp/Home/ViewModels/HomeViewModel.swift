import Foundation
import UIKit

final class HomeViewModel: ObservableObject {
    private let authManager: AuthManager
    private let databaseManager: DatabaseManager
    var listsArray: [ToDoList] = []

    @Published var currentListDate: Date = Date() {
        didSet {
            loadList(forDate: currentListDate)
        }
    }
    
    @Published var isLoading: Bool = false

    @Published var todaysList = ToDoList(dateString: Date().listDateStringFormat(), items: [
    ])

    init(authManager: AuthManager, databaseManager: DatabaseManager) {
        self.authManager = authManager
        self.databaseManager = databaseManager
     
        loadCurrentList()
    }

    func goToPreviousList() {
        if let dayAfter = currentListDate.dayBefore() {
            currentListDate = dayAfter
            
            // this probably shouldn't be in the viewmodel but yolo
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func goToNextList() {
        if let dayBefore = currentListDate.dayAfter() {
            currentListDate = dayBefore
            
            // this probably shouldn't be in the viewmodel but yolo
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func updateCompletionStatus(item: ToDoItem) {
        guard let userId = authManager.signedInUserId(), let index = todaysList.items.firstIndex(where: { $0.id == item.id }) else { return }
            
        todaysList.items[index].isCompleted.toggle()
        
        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: currentListDate)
        } catch let error {
            print("failed to update item with \(error)")
        }
        loadCurrentList()
    }
    
    func addToDoItem(item: ToDoItem) {
        guard let userId = authManager.signedInUserId() else { return }
        todaysList.items.append(item)
        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: currentListDate)
        } catch let error {
            print("failed to add todo item to list with error \(error)")
        }
        loadCurrentList()
    }
    
    @MainActor
    func deleteItem(itemId: UUID) async {
        guard let userId = authManager.signedInUserId(), let index = todaysList.items.firstIndex(where: { $0.id == itemId }) else { return }
        todaysList.items.remove(at: index)

        do {
            try databaseManager.updateList(list: todaysList, userId: userId, forDate: currentListDate)
        } catch let error {
            print("couldn't delete due to error \(error)")
        }
        loadCurrentList()
    }
    
    private func loadCurrentList(showLoadingSpinner: Bool = false) {
        Task { @MainActor in
            isLoading = showLoadingSpinner
            guard let userId = authManager.signedInUserId(), let list = try await databaseManager.fetchList(userId: userId, date: currentListDate) else {
                isLoading = false
                return
            }

            self.todaysList = list
            if let index = self.listsArray.firstIndex(where: { $0.dateString == list.dateString }) {
                self.listsArray[index] = list
            } else {
                self.listsArray.append(list)
            }
            self.isLoading = false
        }
    }

    private func loadList(forDate: Date) {
        let dateString = forDate.listDateStringFormat()
        if let list = listsArray.first(where: {$0.dateString == dateString}) {
            todaysList = list
        } else {
            // create a new empty list if this list is not in the array
            let list = ToDoList(dateString: dateString, items: [])
            listsArray.append(list)
            todaysList = list
            
            // if there's a list for this day stored on the database, retreive it
            // show loading indicator cuz we're loading an entire new list from the api
            loadCurrentList(showLoadingSpinner: true)
        }
    }
}
