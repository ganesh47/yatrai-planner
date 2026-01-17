import Foundation
import Testing
@testable import YatraiPlanner

struct ItineraryServiceTests {
    @Test func fallsBackToDeterministicOnError() async throws {
        let service = ItineraryService(
            client: MockItineraryClient(result: .failure(URLError(.badServerResponse))),
            tokenProvider: MockTokenProvider(token: "token")
        )

        let itinerary = await service.generateItinerary(for: TripInput.sample)
        #expect(itinerary.source == .deterministic)
    }

    @Test func usesAIDraftWhenAvailable() async throws {
        let draft = ItineraryDraftResponse(
            draft: ItineraryDraftPayload(
                days: [ItineraryDayPayload(date: Date(), title: "Day 1", items: ["Start"], estimatedKm: 100)]
            ),
            remaining: 1
        )

        let service = ItineraryService(
            client: MockItineraryClient(result: .success(draft)),
            tokenProvider: MockTokenProvider(token: "token")
        )

        let itinerary = await service.generateItinerary(for: TripInput.sample)
        #expect(itinerary.source == .aiDraft)
        #expect(itinerary.days.count == 1)
    }
}

struct MockTokenProvider: TokenProviding {
    let token: String?

    func fetchToken() async throws -> String {
        if let token {
            return token
        }
        throw TokenError.missingToken
    }
}

struct MockItineraryClient: ItineraryClient {
    let result: Result<ItineraryDraftResponse, Error>

    func fetchDraft(trip: TripInput, token: String) async throws -> ItineraryDraftResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
