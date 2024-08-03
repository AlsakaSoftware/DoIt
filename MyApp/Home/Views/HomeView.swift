import SwiftUI
import RevenueCatUI

struct HomeView: View {
    @EnvironmentObject var coordinator: HomeFlowCoordinator<HomeFlowRouter>
    @StateObject private var viewModel: HomeViewModel
    @State var showPaywallOnLaunch: Bool = true
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State var text: String = "asdasd"
    
    var body: some View {
        VStack {
            headerView
            
            VStack(alignment: .leading) {
                ForEach(viewModel.toDoItems) { item in
                    toDoItemRow(item: item)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 40)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Home")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.designSystem(.primaryBackground).ignoresSafeArea())
        .onAppear {
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
         .background(Color.designSystem(.primaryBackground))
        
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Button {
            } label: {
                Image("left-chevron")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.designSystem(.primaryText))
            }

            Spacer()

            VStack {
                Text("Today")
                 .font(.designSystem(.heading2))
                 .multilineTextAlignment(.center)
                
                Text("August 2nd")
                    .font(.designSystem(.heading3))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                
            } label: {
                Image("right-chevron")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.designSystem(.primaryText))
            }
        }
    }
    
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
                .padding()
            
            Spacer()
        }
        .padding(.horizontal)
        .background(Color.designSystem(.secondaryBackground).opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    let viewModel = HomeViewModel(authManager: AuthManager(), userManager: UserManager())
    return HomeView(viewModel: viewModel)
        .environmentObject(HomeFlowCoordinator<HomeFlowRouter>(authManager: AuthManager(), userManager: UserManager()))
}
