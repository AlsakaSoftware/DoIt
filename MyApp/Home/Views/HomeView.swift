import SwiftUI
import RevenueCatUI

struct HomeView: View {
    @EnvironmentObject var coordinator: HomeFlowCoordinator<HomeFlowRouter>
    @StateObject private var viewModel: HomeViewModel
    @State var showPaywallOnLaunch: Bool = true
    @State private var isShowingAddItemSheet = false

    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State var text: String = "asdasd"
    
    @State private var offset: CGFloat = 0
    @State private var isSwiping: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    headerView
                        .padding(.top, 30)

                    if viewModel.isLoading {
                        Spacer()

                        CircularProgressView()
                        
                        Spacer()
                    } else {
                        listItemsSection
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            addItemButton
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
            }
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isSwiping = true
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width < -10 { // Swipe left
                            withAnimation {
                                viewModel.goToNextList()
                            }
                        } else if value.translation.width > 10 { // Swipe right
                            withAnimation {
                                viewModel.goToPreviousList()
                            }
                        } else {
                            withAnimation {
                                offset = 0
                            }
                        }
                        isSwiping = false
                    }
            )
            .animation(isSwiping ? nil : .snappy, value: offset)

        }
        .background(Color.designSystem(.primaryBackground).ignoresSafeArea())
    }
    
    private var headerView: some View {
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

            VStack {
                Text(viewModel.currentListDate.titleFormat())
                 .font(.designSystem(.heading2))
                 .multilineTextAlignment(.center)
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
    
    var listItemsSection: some View {
        VStack(alignment: .leading) {
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
}


#Preview {
    let viewModel = HomeViewModel(authManager: AuthManager(), databaseManager: DatabaseManager())
    return HomeView(viewModel: viewModel)
        .environmentObject(HomeFlowCoordinator<HomeFlowRouter>(authManager: AuthManager(), databaseManager: DatabaseManager()))
}
