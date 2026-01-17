import SwiftUI

struct ItineraryDraftView: View {
    @Binding var itinerary: Itinerary

    var body: some View {
        NavigationStack {
            List {
                ForEach(itinerary.days.indices, id: \.self) { dayIndex in
                    Section(itinerary.days[dayIndex].title) {
                        ForEach(itinerary.days[dayIndex].items.indices, id: \.self) { itemIndex in
                            TextField(
                                "Item",
                                text: binding(for: dayIndex, itemIndex: itemIndex)
                            )
                        }
                        Button("Add item") {
                            itinerary.days[dayIndex].items.append("")
                        }
                    }
                }
            }
            .navigationTitle("Itinerary draft")
        }
    }

    private func binding(for dayIndex: Int, itemIndex: Int) -> Binding<String> {
        Binding(
            get: { itinerary.days[dayIndex].items[itemIndex] },
            set: { itinerary.days[dayIndex].items[itemIndex] = $0 }
        )
    }
}

#Preview {
    ItineraryDraftView(
        itinerary: .constant(
            Itinerary(
                id: UUID(),
                tripId: UUID(),
                source: .aiDraft,
                days: [
                    ItineraryDay(date: Date(), title: "Day 1", items: ["Start"], estimatedKm: 200)
                ],
                lastUpdated: Date()
            )
        )
    )
}
