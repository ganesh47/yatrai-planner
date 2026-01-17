import Foundation

struct TripInput: Identifiable, Codable {
    var id: UUID
    var startCity: String
    var endCity: String
    var startDate: Date
    var endDate: Date
    var vehicle: Vehicle
    var drivingConstraints: DrivingConstraints
    var familyProfile: FamilyProfile
    var costPreferences: CostPreferences
    var milestones: [Milestone]
    var isProUser: Bool

    static let sample: TripInput = {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 3, to: start) ?? start
        return TripInput(
            id: UUID(),
            startCity: "Chennai",
            endCity: "Mumbai",
            startDate: start,
            endDate: end,
            vehicle: Vehicle(name: "Innova", fuelType: .diesel, mileageKmPerLiter: 13, fuelPricePerLiter: 98),
            drivingConstraints: DrivingConstraints(
                maxKmPerDay: 350,
                avoidNightDriving: true,
                breakEveryHours: 3,
                breakDurationMinutes: 20
            ),
            familyProfile: FamilyProfile(
                adults: 2,
                kids: [
                    Kid(name: "Kid 1", ageMonths: 18),
                    Kid(name: "Kid 2", ageMonths: 72)
                ]
            ),
            costPreferences: CostPreferences(
                foodType: .mixed,
                dailyFoodBudget: 2500,
                lodgingBudget: 4000
            ),
            milestones: [
                Milestone(type: .standard(.temple), name: "Tirupati", mustDo: true, timeWindow: nil, notes: "Avoid Ekadashi"),
                Milestone(type: .standard(.town), name: "Pune", mustDo: false, timeWindow: nil, notes: nil)
            ],
            isProUser: false
        )
    }()
}

struct Vehicle: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var fuelType: FuelType
    var mileageKmPerLiter: Double
    var fuelPricePerLiter: Double
}

enum FuelType: String, CaseIterable, Codable, Identifiable {
    case petrol
    case diesel
    case electric
    case cng

    var id: String { rawValue }
}

struct DrivingConstraints: Codable {
    var maxKmPerDay: Int
    var avoidNightDriving: Bool
    var breakEveryHours: Int
    var breakDurationMinutes: Int
}

struct FamilyProfile: Codable {
    var adults: Int
    var kids: [Kid]
}

struct Kid: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var ageMonths: Int
}

struct CostPreferences: Codable {
    var foodType: FoodType
    var dailyFoodBudget: Int
    var lodgingBudget: Int
}

enum FoodType: String, CaseIterable, Codable, Identifiable {
    case veg
    case nonVeg
    case mixed

    var id: String { rawValue }
}

struct Milestone: Identifiable, Codable {
    var id: UUID = UUID()
    var type: MilestoneType
    var name: String
    var mustDo: Bool
    var timeWindow: TimeWindow?
    var notes: String?
}

struct TimeWindow: Codable {
    var start: Date?
    var end: Date?
}

enum MilestoneType: Codable, Identifiable, Equatable {
    case standard(StandardMilestoneType)
    case custom(String)

    var id: String {
        switch self {
        case .standard(let value):
            return "standard-\(value.rawValue)"
        case .custom(let value):
            return "custom-\(value)"
        }
    }

    var label: String {
        switch self {
        case .standard(let value):
            return value.label
        case .custom(let value):
            return value.isEmpty ? "Custom" : value
        }
    }
}

enum StandardMilestoneType: String, CaseIterable, Codable, Identifiable {
    case town
    case temple
    case hotel
    case food
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .town:
            return "Town"
        case .temple:
            return "Temple"
        case .hotel:
            return "Hotel"
        case .food:
            return "Food"
        case .other:
            return "Other"
        }
    }
}
