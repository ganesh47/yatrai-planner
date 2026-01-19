import Foundation

struct ItineraryDraftPayload: Codable {
    var days: [ItineraryDayPayload]
}

struct ItineraryDayPayload: Codable {
    var date: Date?
    var title: String
    var items: [String]
    var estimatedKm: Int?
}

struct ItineraryDraftResponse: Codable {
    var draft: ItineraryDraftPayload
    var remaining: Int?
}

protocol ItineraryClient {
    func fetchDraft(trip: TripInput, token: String) async throws -> ItineraryDraftResponse
}

struct NetworkItineraryClient: ItineraryClient {
    var baseURL: URL

    func fetchDraft(trip: TripInput, token: String) async throws -> ItineraryDraftResponse {
        let url = baseURL.appendingPathComponent("itinerary")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(tripRequestPayload(from: trip))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ItineraryDraftResponse.self, from: data)
    }

    private func tripRequestPayload(from trip: TripInput) -> [String: String] {
        let formatter = ISO8601DateFormatter()
        return [
            "startCity": trip.startCity,
            "endCity": trip.endCity,
            "startDate": formatter.string(from: trip.startDate),
            "endDate": formatter.string(from: trip.endDate)
        ]
    }
}

struct ItineraryService {
    var client: ItineraryClient
    var tokenProvider: TokenProviding
    var planner: DeterministicPlanner = DeterministicPlanner()

    func generateItinerary(for trip: TripInput) async -> Itinerary {
        do {
            let token = try await tokenProvider.fetchToken()
            let response = try await client.fetchDraft(trip: trip, token: token)
            let itinerary = mapDraft(response.draft, tripId: trip.id)
            return sanitize(itinerary, trip: trip)
        } catch {
            let itinerary = planner.generate(trip: trip)
            return sanitize(itinerary, trip: trip)
        }
    }

    private func mapDraft(_ draft: ItineraryDraftPayload, tripId: UUID) -> Itinerary {
        let days = draft.days.map { day in
            ItineraryDay(
                date: day.date ?? Date(),
                title: day.title,
                items: day.items,
                estimatedKm: day.estimatedKm
            )
        }

        return Itinerary(
            id: UUID(),
            tripId: tripId,
            source: .aiDraft,
            days: days,
            lastUpdated: Date()
        )
    }

    private func sanitize(_ itinerary: Itinerary, trip: TripInput) -> Itinerary {
        let filteredDays = itinerary.days.filter { day in
            day.items.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }

        if filteredDays.isEmpty {
            let items = [
                "Start: \(trip.startCity)",
                "End: \(trip.endCity)"
            ]
            let fallbackDay = ItineraryDay(
                date: trip.startDate,
                title: "Day 1",
                items: items,
                estimatedKm: trip.drivingConstraints.maxKmPerDay
            )
            return Itinerary(
                id: itinerary.id,
                tripId: itinerary.tripId,
                source: itinerary.source,
                days: [fallbackDay],
                lastUpdated: itinerary.lastUpdated
            )
        }

        return Itinerary(
            id: itinerary.id,
            tripId: itinerary.tripId,
            source: itinerary.source,
            days: filteredDays,
            lastUpdated: itinerary.lastUpdated
        )
    }
}
