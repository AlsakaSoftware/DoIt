import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var coordinator: HomeFlowCoordinator<HomeFlowRouter>
    @Environment(\.dismiss) var dismiss

    @State private var item: ToDoItem
    private var onAddItem: ((ToDoItem) -> Void)?

    init(itemIndex: Int, onAddItem: ((ToDoItem) -> Void)? = nil) {
        let item = ToDoItem(id: UUID(),
                            dayIndex: itemIndex,
                            title: "",
                            description: "",
                            isMainTask: false,
                            isCompleted: false
        )

        self.onAddItem = onAddItem
        self._item = State(initialValue: item)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Add Item")
                    .font(.designSystem(.heading2))
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Title")
                        .font(.designSystem(.heading4))
                    TextField("Title", text: $item.title)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        .background(Color.designSystem(.secondaryBackground).opacity(0.5))
                        .cornerRadius(10)
                    
                    Text("Description")
                        .font(.designSystem(.heading4))
                    TextField("Description", text: $item.description)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        .background(Color.designSystem(.secondaryBackground).opacity(0.5))
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)

                PrimaryButton {
                    onAddItem?(item)
                    dismiss()
                } label: {
                    Text("Add Item")
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .navigationTitle("Add Item")
            .frame(maxWidth: .infinity)
        }
        .background(Color.designSystem(.primaryBackground).ignoresSafeArea())
    }
}

#Preview {
    AddItemView(itemIndex: 1)
}
