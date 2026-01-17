import Foundation
import Testing
@testable import YatraiPlanner

struct RepositoryTests {
    @Test func tripRepositoryCRUD() async throws {
        let repo = InMemoryTripRepository()
        let trip = TripInput.sample

        #expect(repo.listTrips().isEmpty)

        repo.upsert(trip)
        #expect(repo.listTrips().count == 1)
        #expect(repo.trip(id: trip.id) != nil)

        repo.delete(id: trip.id)
        #expect(repo.listTrips().isEmpty)
        #expect(repo.trip(id: trip.id) == nil)
    }

    @Test func milestoneRepositoryCRUD() async throws {
        let repo = InMemoryMilestoneRepository()
        let tripId = UUID()
        let milestones = [
            Milestone(type: .standard(.town), name: "Pune", mustDo: false, timeWindow: nil, notes: nil),
            Milestone(type: .standard(.temple), name: "Tirupati", mustDo: true, timeWindow: nil, notes: nil)
        ]

        #expect(repo.milestones(for: tripId).isEmpty)
        repo.setMilestones(milestones, for: tripId)
        #expect(repo.milestones(for: tripId).count == 2)

        repo.deleteMilestones(for: tripId)
        #expect(repo.milestones(for: tripId).isEmpty)
    }

    @Test func itineraryRepositoryCRUD() async throws {
        let repo = InMemoryItineraryRepository()
        let tripId = UUID()
        let itinerary = Itinerary(
            id: UUID(),
            tripId: tripId,
            source: .deterministic,
            days: [
                ItineraryDay(date: Date(), title: "Day 1", items: ["Start"], estimatedKm: 280)
            ],
            lastUpdated: Date()
        )

        #expect(repo.itinerary(for: tripId) == nil)
        repo.save(itinerary)
        #expect(repo.itinerary(for: tripId) != nil)

        repo.deleteItinerary(for: tripId)
        #expect(repo.itinerary(for: tripId) == nil)
    }
}
