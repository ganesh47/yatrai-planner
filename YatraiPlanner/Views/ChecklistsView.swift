import SwiftUI

#if CODEQL
struct ChecklistsView: View {
    @Binding var checklists: [Checklist]

    var body: some View {
        Text("Checklists")
            .navigationTitle("Checklists")
            .toolbar {
                Button("Add checklist") {
                    checklists.append(Checklist(title: "New checklist", items: []))
                }
            }
    }
}
#else
struct ChecklistsView: View {
    @Binding var checklists: [Checklist]

    var body: some View {
        List {
            ForEach(checklists.indices, id: \.self) { checklistIndex in
                Section(checklists[checklistIndex].title) {
                    ForEach(checklists[checklistIndex].items.indices, id: \.self) { itemIndex in
                        ChecklistItemRow(item: bindingForItem(checklistIndex: checklistIndex, itemIndex: itemIndex))
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

    private func bindingForItem(checklistIndex: Int, itemIndex: Int) -> Binding<ChecklistItem> {
        Binding(
            get: { checklists[checklistIndex].items[itemIndex] },
            set: { checklists[checklistIndex].items[itemIndex] = $0 }
        )
    }
}

private struct ChecklistItemRow: View {
    @Binding var item: ChecklistItem

    var body: some View {
        HStack {
            Button {
                item.isDone.toggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.borderless)

            TextField("Item", text: $item.title)
        }
    }
}
#endif

#Preview {
    ChecklistsView(checklists: .constant(TripInput.sample.checklists))
}
