import Foundation

protocol TripRepository {
    func listTrips() -> [TripInput]
    func trip(id: UUID) -> TripInput?
    func upsert(_ trip: TripInput)
    func delete(id: UUID)
}

protocol MilestoneRepository {
    func milestones(for tripId: UUID) -> [Milestone]
    func setMilestones(_ milestones: [Milestone], for tripId: UUID)
    func deleteMilestones(for tripId: UUID)
}

protocol ItineraryRepository {
    func itinerary(for tripId: UUID) -> Itinerary?
    func save(_ itinerary: Itinerary)
    func deleteItinerary(for tripId: UUID)
}

final class InMemoryTripRepository: TripRepository {
    private var storage: [UUID: TripInput] = [:]

    func listTrips() -> [TripInput] {
        storage.values.sorted { $0.startDate < $1.startDate }
    }

    func trip(id: UUID) -> TripInput? {
        storage[id]
    }

    func upsert(_ trip: TripInput) {
        storage[trip.id] = trip
    }

    func delete(id: UUID) {
        storage.removeValue(forKey: id)
    }
}

final class InMemoryMilestoneRepository: MilestoneRepository {
    private var storage: [UUID: [Milestone]] = [:]

    func milestones(for tripId: UUID) -> [Milestone] {
        storage[tripId] ?? []
    }

    func setMilestones(_ milestones: [Milestone], for tripId: UUID) {
        storage[tripId] = milestones
    }

    func deleteMilestones(for tripId: UUID) {
        storage.removeValue(forKey: tripId)
    }
}

final class InMemoryItineraryRepository: ItineraryRepository {
    private var storage: [UUID: Itinerary] = [:]

    func itinerary(for tripId: UUID) -> Itinerary? {
        storage[tripId]
    }

    func save(_ itinerary: Itinerary) {
        storage[itinerary.tripId] = itinerary
    }

    func deleteItinerary(for tripId: UUID) {
        storage.removeValue(forKey: tripId)
    }
}
