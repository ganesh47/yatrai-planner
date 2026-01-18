import Foundation

struct DeterministicPlanner {
    func generate(trip: TripInput) -> Itinerary {
        let dates = tripDates(start: trip.startDate, end: trip.endDate)
        let dayCount = max(dates.count, 1)
        let milestones = trip.milestones
        let chunkSize = max(1, Int(ceil(Double(milestones.count) / Double(dayCount))))

        var days: [ItineraryDay] = []
        for index in 0..<dayCount {
            let startIndex = index * chunkSize
            let endIndex = min(startIndex + chunkSize, milestones.count)
            let slice = startIndex < endIndex ? Array(milestones[startIndex..<endIndex]) : []
            let date = dates.indices.contains(index) ? dates[index] : trip.startDate

            var items: [String] = []
            if index == 0 {
                items.append("Start: \(trip.startCity)")
            }
            let milestoneItems = slice.map { "Milestone: \($0.name.isEmpty ? $0.type.label : $0.name)" }
            if trip.isProUser {
                items.append(contentsOf: milestoneItems)
            } else {
                items.append(contentsOf: milestoneItems.prefix(2))
            }
            if index == dayCount - 1 {
                items.append("End: \(trip.endCity)")
            }

            let day = ItineraryDay(
                date: date,
                title: "Day \(index + 1)",
                items: items,
                estimatedKm: trip.drivingConstraints.maxKmPerDay
            )
            days.append(day)
        }

        return Itinerary(
            id: UUID(),
            tripId: trip.id,
            source: .deterministic,
            days: days,
            lastUpdated: Date()
        )
    }

    private func tripDates(start: Date, end: Date) -> [Date] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        if endDay < startDay {
            return [start]
        }

        var dates: [Date] = []
        var current = startDay
        while current <= endDay {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates.isEmpty ? [start] : dates
    }
}
