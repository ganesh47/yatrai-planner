import Foundation

struct TripCost: Codable, Equatable {
    var fuelCost: Double
    var foodCost: Double
    var lodgingCost: Double
    var totalCost: Double
}

struct CostCalculator {
    func estimateCost(for trip: TripInput) -> TripCost {
        let dayCount = max(1, Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0) + 1
        let totalKm = Double(dayCount * trip.drivingConstraints.maxKmPerDay)
        let fuelCost = (totalKm / max(trip.vehicle.mileageKmPerLiter, 1)) * trip.vehicle.fuelPricePerLiter
        let foodCost = Double(dayCount * trip.costPreferences.dailyFoodBudget)
        let lodgingCost = Double(dayCount * trip.costPreferences.lodgingBudget)
        let totalCost = fuelCost + foodCost + lodgingCost
        return TripCost(fuelCost: fuelCost, foodCost: foodCost, lodgingCost: lodgingCost, totalCost: totalCost)
    }
}
