import Foundation
import MapKit

final class LocationResolver {
    static let shared = LocationResolver()

    private struct CachedLocation: Codable {
        let latitude: Double
        let longitude: Double
    }

    private let cacheKey = "yatrai.location.cache"
    private let defaults = UserDefaults.standard

    private init() {}

    func resolve(query: String) async -> CLLocationCoordinate2D? {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        if let cached = cachedLocation(for: normalized) {
            return cached
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = normalized
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            if let coordinate = response.mapItems.first?.location?.coordinate {
                store(coordinate: coordinate, for: normalized)
                return coordinate
            }
        } catch {
            return nil
        }
        return nil
    }

    private func cachedLocation(for query: String) -> CLLocationCoordinate2D? {
        guard let data = defaults.data(forKey: cacheKey) else { return nil }
        guard let decoded = try? JSONDecoder().decode([String: CachedLocation].self, from: data) else {
            return nil
        }
        guard let cached = decoded[query] else { return nil }
        return CLLocationCoordinate2D(latitude: cached.latitude, longitude: cached.longitude)
    }

    private func store(coordinate: CLLocationCoordinate2D, for query: String) {
        var cache: [String: CachedLocation] = [:]
        if let data = defaults.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: CachedLocation].self, from: data) {
            cache = decoded
        }
        cache[query] = CachedLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let data = try? JSONEncoder().encode(cache) {
            defaults.set(data, forKey: cacheKey)
        }
    }
}
