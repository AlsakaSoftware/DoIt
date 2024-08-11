import SwiftUI
import RevenueCatUI

struct HomeView: View {
    @EnvironmentObject var coordinator: HomeFlowCoordinator<HomeFlowRouter>
    @StateObject private var viewModel: HomeViewModel
    @State private var showPaywallOnLaunch: Bool = true
    @State private var isShowingAddItemSheet = false
    @State private var draggedItem: ToDoItem?

    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            header

            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            Spacer()

                            CircularProgressView()

                            Spacer()
                        } else {
                            listItemsSection
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height)
                }
            }

            HStack {
                addItemButton
                showWeeklyItemsButton
            }
            .padding(.bottom, 20)

            footer
                .padding(.horizontal, 30)
            
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.designSystem(.primaryBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            coordinator.navigationController.setNavigationBarHidden(true, animated: false)
            coordinator.showATTPermissionsAlert()
            
            if showPaywallOnLaunch {
                showPaywallOnLaunch = false
                Task {
                    if await !PurchasesManager.shared.getSubscriptionStatus() {
                        coordinator.show(.paywall)
                    }
                }
            }
        }
    }
    
    private var footer: some View {
        HStack(alignment: .center) {
            Button {
                viewModel.goToPreviousList()
            } label: {
                Image("left-chevron")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.designSystem(.primaryText))
            }

            Spacer()

            Button {
                viewModel.goToNextList()
            } label: {
                Image("right-chevron")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.designSystem(.primaryText))
            }
        }
    }
    
    var header: some View {
        VStack(alignment: .center) {
            Text(viewModel.currentListDate.titleFormat())
             .font(.designSystem(.heading2))
             .multilineTextAlignment(.center)
        }
    }
    
    var listItemsSection: some View {
        VStack(alignment: .leading) {
            
            if viewModel.todaysList.items.count == 0 {
                emptyItemsSection()
            }
            
            if viewModel.todaysList.items.count > 0 {
                mainTasksSection(items: Array(viewModel.todaysList.items.prefix(3)))
                    .padding(.bottom, 10)
            }
            
            if viewModel.todaysList.items.count > 3 {
                secondaryTasksSection(items: Array(viewModel.todaysList.items.dropFirst(3)))
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    func emptyItemsSection() -> some View {
        VStack {
            Spacer()
            Group {
                Text("You have no items for today, use the ")
                    .font(.designSystem(.body1))
                + Text("+ ")
                    .font(.designSystem(.heading2))
                    .foregroundColor(Color.designSystem(.primaryControlBackground))
                
                + Text("button below to add a new item!")
                    .font(.designSystem(.body1))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func mainTasksSection(items: [ToDoItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Main")
                .font(.designSystem(.heading3))

            ForEach(items) { item in
                toDoItemRow(item: item)
            }
        }
    }
    
    @ViewBuilder
    func secondaryTasksSection(items: [ToDoItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Other")
                .font(.designSystem(.heading3))

            ForEach(items) { item in
                toDoItemRow(item: item)
            }
        }
    }

    
    // MARK: Components

    @ViewBuilder
    func toDoItemRow(item: ToDoItem) -> some View {    
        HStack {
            Button {
                viewModel.updateCompletionStatus(item: item)
            } label: {
                Image(item.isCompleted ? "checkbox-checked-filled" : "checkbox-unchecked")
                    .resizable()
                    .frame(width: 35, height: 35)

            }
            .foregroundStyle(Color.designSystem(.primaryControlBackground))
            
            Text(item.title)
                .padding(.horizontal, 5)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.deleteItem(itemId: item.id)
                }
            } label: {
                Image("trash-icon")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.designSystem(.primaryControlBackground))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)

        .background(Color.designSystem(.secondaryBackground).opacity(0.5))
        .cornerRadius(10)
        .onDrag {
            self.draggedItem = item
            return NSItemProvider()
        }
        .onDrop(of: [.toDoItem],
                delegate: ToDoListDropViewDelegate(destinationItem: item, items: $viewModel.todaysList.items, draggedItem: $draggedItem)
        )
    }
    
    private var addItemButton: some View {
        Button {
            coordinator.show(.addItem(onAddItem: { item in
                viewModel.addToDoItem(item: item)
            }))
        } label: {
            Image("plus-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
                .padding(20)
                .background(Circle().fill(Color.designSystem(.primaryControlBackground)))
        }
        .frame(width: 60, height: 60)

    }
    
    private var showWeeklyItemsButton: some View {
        Button {

        } label: {
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
                .padding(20)
                .background(Circle().fill(Color.designSystem(.primaryControlBackground)))
        }
        .frame(width: 60, height: 60)
    }
}


#Preview {
    let viewModel = HomeViewModel(authManager: AuthManager(), databaseManager: DatabaseManager())
    return HomeView(viewModel: viewModel)
        .environmentObject(HomeFlowCoordinator<HomeFlowRouter>(authManager: AuthManager(), databaseManager: DatabaseManager()))
}
