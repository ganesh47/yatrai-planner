import SwiftUI

struct ChecklistsView: View {
    @Binding var checklists: [Checklist]

    var body: some View {
        List {
            ForEach($checklists) { $checklist in
                Section(checklist.title) {
                    ForEach($checklist.items) { $item in
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
                    .onDelete { offsets in
                        checklist.items.remove(atOffsets: offsets)
                    }

                    Button("Add item") {
                        checklist.items.append(ChecklistItem(title: ""))
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
