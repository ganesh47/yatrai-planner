import Foundation

struct Itinerary: Identifiable, Codable {
    var id: UUID
    var tripId: UUID
    var source: ItinerarySource
    var days: [ItineraryDay]
    var lastUpdated: Date
}

enum ItinerarySource: String, Codable {
    case deterministic
    case aiDraft
}

struct ItineraryDay: Codable {
    var date: Date
    var title: String
    var items: [String]
    var estimatedKm: Int?
}
