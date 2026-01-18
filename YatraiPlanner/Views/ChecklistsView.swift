import SwiftUI

struct ChecklistsView: View {
    @Binding var checklists: [Checklist]

    var body: some View {
        List {
            ForEach(checklists.indices, id: \.self) { checklistIndex in
                let checklist = checklists[checklistIndex]
                Section(checklist.title) {
                    ForEach(checklist.items.indices, id: \.self) { itemIndex in
                        let isDone = Binding(
                            get: { checklists[checklistIndex].items[itemIndex].isDone },
                            set: { checklists[checklistIndex].items[itemIndex].isDone = $0 }
                        )
                        let title = Binding(
                            get: { checklists[checklistIndex].items[itemIndex].title },
                            set: { checklists[checklistIndex].items[itemIndex].title = $0 }
                        )
                        HStack {
                            Button {
                                isDone.wrappedValue.toggle()
                            } label: {
                                Image(systemName: isDone.wrappedValue ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.borderless)

                            TextField("Item", text: title)
                        }
                    }
                    .onDelete { offsets in
                        checklists[checklistIndex].items.remove(atOffsets: offsets)
                    }

                    Button("Add item") {
                        checklists[checklistIndex].items.append(ChecklistItem(title: ""))
                    }
                }
            }
            .onDelete { offsets in
                checklists.remove(atOffsets: offsets)
            }
        }
        .navigationTitle("Checklists")
        .toolbar {
            Button("Add checklist") {
                checklists.append(Checklist(title: "New checklist", items: []))
            }
        }
    }
}

#Preview {
    ChecklistsView(checklists: .constant(TripInput.sample.checklists))
}
