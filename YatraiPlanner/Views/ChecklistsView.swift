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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(checklists.indices, id: \.self) { checklistIndex in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(checklists[checklistIndex].title)
                                .font(.headline)
                            Spacer()
                            Button("Remove") {
                                checklists.remove(at: checklistIndex)
                            }
                            .buttonStyle(.borderless)
                        }

                        ForEach(checklists[checklistIndex].items.indices, id: \.self) { itemIndex in
                            ChecklistItemRow(
                                item: bindingForItem(checklistIndex: checklistIndex, itemIndex: itemIndex),
                                onDelete: {
                                    checklists[checklistIndex].items.remove(at: itemIndex)
                                }
                            )
                        }

                        Button("Add item") {
                            checklists[checklistIndex].items.append(ChecklistItem(title: ""))
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.systemBackground)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }
            }
            .padding()
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
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Button {
                item.isDone.toggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.borderless)

            TextField("Item", text: $item.title)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
    }
}
#endif

#Preview {
    ChecklistsView(checklists: .constant(TripInput.sample.checklists))
}
