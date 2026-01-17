import Foundation

struct PlannerIssue: Identifiable, Equatable {
    enum Kind: String {
        case invalidDateRange
        case invalidMaxKmPerDay
        case nightDrivingNotAllowed
        case missingCities
    }

    var id: String { kind.rawValue }
    var kind: Kind
    var message: String
}

struct PlannerValidation {
    func validate(trip: TripInput) -> [PlannerIssue] {
        var issues: [PlannerIssue] = []

        if trip.startCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            trip.endCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(PlannerIssue(kind: .missingCities, message: "Start and end cities are required."))
        }

        if trip.endDate < trip.startDate {
            issues.append(PlannerIssue(kind: .invalidDateRange, message: "End date must be after start date."))
        }

        if trip.drivingConstraints.maxKmPerDay <= 0 {
            issues.append(PlannerIssue(kind: .invalidMaxKmPerDay, message: "Max km/day must be positive."))
        }

        if trip.drivingConstraints.avoidNightDriving {
            if isNight(trip.startDate) || isNight(trip.endDate) {
                issues.append(PlannerIssue(kind: .nightDrivingNotAllowed, message: "Trip times must avoid night driving."))
            }
        }

        return issues
    }

    private func isNight(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 22 || hour < 5
    }
}
