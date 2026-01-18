import MapKit
import SwiftUI

struct MapPreviewView: View {
    let query: String?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var isLoading = false
    @State private var hasCoordinate = false

    var body: some View {
        ZStack {
            if hasCoordinate {
                Map(coordinateRegion: $region, interactionModes: [])
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "map")
                                .foregroundStyle(.secondary)
                            Text(isLoading ? "Loading map…" : "Map preview unavailable")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
            }
        }
        .task(id: query) {
            await resolveLocation()
        }
    }

    @MainActor
    private func resolveLocation() async {
        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            hasCoordinate = false
            return
        }
        isLoading = true
        if let coordinate = await LocationResolver.shared.resolve(query: query) {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
            hasCoordinate = true
        } else {
            hasCoordinate = false
        }
        isLoading = false
    }
}

#Preview {
    MapPreviewView(query: "Chennai")
}
