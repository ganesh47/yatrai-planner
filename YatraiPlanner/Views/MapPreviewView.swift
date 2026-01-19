import MapKit
import SwiftUI

struct MapPreviewView: View {
    let startQuery: String?
    let endQuery: String?
    @State private var startCoordinate: CLLocationCoordinate2D?
    @State private var endCoordinate: CLLocationCoordinate2D?
    @State private var route: MKPolyline?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let startCoordinate {
                MapRouteView(start: startCoordinate, end: endCoordinate, polyline: route)
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
        .task(id: cacheKey) {
            await resolveLocations()
        }
    }

    private var cacheKey: String {
        [startQuery ?? "", endQuery ?? ""].joined(separator: "|")
    }

    @MainActor
    private func resolveLocations() async {
        isLoading = true
        defer { isLoading = false }
        startCoordinate = await resolve(query: startQuery)
        endCoordinate = await resolve(query: endQuery)

        if let start = startCoordinate, let end = endCoordinate {
            route = await computeRoute(from: start, to: end)
        } else {
            route = nil
        }
    }

    private func resolve(query: String?) async -> CLLocationCoordinate2D? {
        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return await LocationResolver.shared.resolve(query: query)
    }

    private func computeRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) async -> MKPolyline? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            return response.routes.first?.polyline
        } catch {
            return nil
        }
    }
}

private struct MapRouteView: UIViewRepresentable {
    let start: CLLocationCoordinate2D
    let end: CLLocationCoordinate2D?
    let polyline: MKPolyline?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = start
        mapView.addAnnotation(startAnnotation)

        if let end {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = end
            mapView.addAnnotation(endAnnotation)
        }

        if let polyline {
            mapView.addOverlay(polyline)
            let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: padding, animated: false)
        } else {
            let region = MKCoordinateRegion(center: start, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            mapView.setRegion(region, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

#Preview {
    MapPreviewView(startQuery: "Chennai", endQuery: "Bengaluru")
}
