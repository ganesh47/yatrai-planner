import Foundation
import Testing
@testable import YatraiPlanner

struct PlannerTests {
    @Test func validationFlagsNightDriving() async throws {
        var trip = TripInput.sample
        trip.drivingConstraints.avoidNightDriving = true
        trip.startDate = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
        let issues = PlannerValidation().validate(trip: trip)
        #expect(issues.contains { $0.kind == .nightDrivingNotAllowed })
    }

    @Test func plannerDistributesMilestonesByDay() async throws {
        var trip = TripInput.sample
        trip.startDate = Date()
        trip.endDate = Calendar.current.date(byAdding: .day, value: 2, to: trip.startDate) ?? trip.startDate
        trip.milestones = [
            Milestone(type: .standard(.town), name: "Stop 1", mustDo: true, timeWindow: nil, notes: nil),
            Milestone(type: .standard(.temple), name: "Stop 2", mustDo: false, timeWindow: nil, notes: nil),
            Milestone(type: .standard(.hotel), name: "Stop 3", mustDo: true, timeWindow: nil, notes: nil),
            Milestone(type: .standard(.food), name: "Stop 4", mustDo: false, timeWindow: nil, notes: nil),
            Milestone(type: .standard(.other), name: "Stop 5", mustDo: false, timeWindow: nil, notes: nil)
        ]

        let itinerary = DeterministicPlanner().generate(trip: trip)
        #expect(itinerary.days.count == 3)

        let allItems = itinerary.days.flatMap { $0.items }
        let milestoneOrder = allItems.filter { $0.hasPrefix("Milestone") }
        #expect(milestoneOrder.count == 5)
        #expect(milestoneOrder.first?.contains("Stop 1") == true)
        #expect(milestoneOrder.last?.contains("Stop 5") == true)
    }

    @Test func costCalculatorMatchesExpected() async throws {
        var trip = TripInput.sample
        trip.startDate = Date()
        trip.endDate = Calendar.current.date(byAdding: .day, value: 1, to: trip.startDate) ?? trip.startDate
        trip.drivingConstraints.maxKmPerDay = 200
        trip.vehicle.mileageKmPerLiter = 10
        trip.vehicle.fuelPricePerLiter = 100
        trip.costPreferences.dailyFoodBudget = 1000
        trip.costPreferences.lodgingBudget = 2000

        let cost = CostCalculator().estimateCost(for: trip)
        #expect(cost.fuelCost == 4000)
        #expect(cost.foodCost == 2000)
        #expect(cost.lodgingCost == 4000)
        #expect(cost.totalCost == 10000)
    }
}

struct FixtureTests {
    @Test func loadsSampleTripFixture() async throws {
        let bundle = Bundle(for: FixtureToken.self)
        guard let url = bundle.url(forResource: "SampleTrip", withExtension: "json") else {
            #expect(Bool(false))
            return
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let trip = try decoder.decode(TripInput.self, from: data)
        #expect(trip.startCity == "Chennai")
        #expect(trip.milestones.count == 2)
    }
}

final class FixtureToken: NSObject {}
