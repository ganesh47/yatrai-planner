import SwiftUI

struct OutputHubView: View {
    @Binding var trip: TripInput
    @Binding var itinerary: Itinerary?

    var body: some View {
        List {
            Section("Outputs") {
                NavigationLink {
                    if let itineraryBinding = bindingForItinerary() {
                        ItineraryDraftView(itinerary: itineraryBinding, isProUser: trip.isProUser)
                    } else {
                        Text("Generate an itinerary to view details.")
                            .foregroundStyle(.secondary)
                    }
                } label: {
                    OutputSummaryCard(
                        title: "Itinerary",
                        subtitle: itinerarySubtitle,
                        detail: itineraryDetail
                    )
                }

                NavigationLink {
                    ChecklistsView(checklists: $trip.checklists)
                } label: {
                    OutputSummaryCard(
                        title: "Checklist",
                        subtitle: "\(totalChecklistItems) items",
                        detail: "Tap to review"
                    )
                }

                NavigationLink {
                    CostSummaryView(trip: trip)
                } label: {
                    OutputSummaryCard(
                        title: "Cost summary",
                        subtitle: costSubtitle,
                        detail: "Tap for breakdown"
                    )
                }
            }
        }
        .navigationTitle("Trip outputs")
    }

    private var totalChecklistItems: Int {
        trip.checklists.reduce(0) { $0 + $1.items.count }
    }

    private var itinerarySubtitle: String {
        guard let itinerary else { return "Not generated yet" }
        return "\(itinerary.days.count) days"
    }

    private var itineraryDetail: String {
        guard let itinerary else { return "Generate to continue" }
        return itinerary.source == .aiDraft ? "AI draft" : "Deterministic"
    }

    private var costSubtitle: String {
        let cost = CostCalculator().estimateCost(for: trip)
        return String(format: "Total %.0f", cost.totalCost)
    }

    private func bindingForItinerary() -> Binding<Itinerary>? {
        guard itinerary != nil else { return nil }
        return Binding(
            get: { itinerary ?? tripFallbackItinerary() },
            set: { itinerary = $0 }
        )
    }

    private func tripFallbackItinerary() -> Itinerary {
        Itinerary(id: trip.id, tripId: trip.id, source: .deterministic, days: [], lastUpdated: Date())
    }
}

private struct OutputSummaryCard: View {
    let title: String
    let subtitle: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct CostSummaryView: View {
    let trip: TripInput

    var body: some View {
        let cost = CostCalculator().estimateCost(for: trip)
        List {
            Section("Summary") {
                CostRow(label: "Fuel", value: cost.fuelCost)
                CostRow(label: "Food", value: cost.foodCost)
                CostRow(label: "Lodging", value: cost.lodgingCost)
                CostRow(label: "Total", value: cost.totalCost, isEmphasized: true)
            }
        }
        .navigationTitle("Cost summary")
    }
}

private struct CostRow: View {
    let label: String
    let value: Double
    var isEmphasized = false

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(isEmphasized ? .semibold : .regular)
            Spacer()
            Text(String(format: "%.0f", value))
                .fontWeight(isEmphasized ? .semibold : .regular)
        }
    }
}

#Preview {
    NavigationStack {
        OutputHubView(trip: .constant(.sample), itinerary: .constant(nil))
    }
}
