import SwiftUI

struct ItineraryDraftView: View {
    @Binding var itinerary: Itinerary

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(itinerary.days.indices, id: \.self) { dayIndex in
                        dayCard(dayIndex)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Itinerary draft")
        }
    }

    private func dayCard(_ dayIndex: Int) -> some View {
        let day = itinerary.days[dayIndex]
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(day.title)
                    .font(.headline)
                Spacer()
                if let estimatedKm = day.estimatedKm {
                    Text("\(estimatedKm) km")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            tableHeader
            ForEach(day.items.indices, id: \.self) { itemIndex in
                tableRow(
                    dayIndex: dayIndex,
                    itemIndex: itemIndex,
                    isStriped: itemIndex % 2 == 1
                )
            }
            Button {
                itinerary.days[dayIndex].items.append("")
            } label: {
                Label("Add item", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var tableHeader: some View {
        HStack(spacing: 12) {
            Text("#")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)
            Text("Stop")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 6)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(.separator)),
            alignment: .bottom
        )
    }

    private func tableRow(dayIndex: Int, itemIndex: Int, isStriped: Bool) -> some View {
        HStack(spacing: 12) {
            Text("\(itemIndex + 1)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)
            TextField("Item", text: binding(for: dayIndex, itemIndex: itemIndex))
                .textFieldStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(isStriped ? Color(.systemGray6) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
