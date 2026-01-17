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
            return mapDraft(response.draft, tripId: trip.id)
        } catch {
            return planner.generate(trip: trip)
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
}
