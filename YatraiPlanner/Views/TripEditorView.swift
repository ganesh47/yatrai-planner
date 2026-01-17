import SwiftUI

struct TripEditorView: View {
    @State private var trip: TripInput = .sample

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    TextField("Starting city", text: $trip.startCity)
                    TextField("Ending city", text: $trip.endCity)
                }

                Section("Trip dates") {
                    DatePicker("Start", selection: $trip.startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $trip.endDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Vehicle") {
                    TextField("Vehicle name", text: $trip.vehicle.name)
                    Picker("Fuel type", selection: $trip.vehicle.fuelType) {
                        ForEach(FuelType.allCases) { fuel in
                            Text(fuel.rawValue.capitalized).tag(fuel)
                        }
                    }
                    Stepper(value: $trip.vehicle.mileageKmPerLiter, in: 5...30, step: 0.5) {
                        HStack {
                            Text("Mileage")
                            Spacer()
                            Text(String(format: "%.1f km/L", trip.vehicle.mileageKmPerLiter))
                        }
                    }
                    Stepper(value: $trip.vehicle.fuelPricePerLiter, in: 50...200, step: 1) {
                        HStack {
                            Text("Fuel price")
                            Spacer()
                            Text("\(Int(trip.vehicle.fuelPricePerLiter)) / L")
                        }
                    }
                }

                Section("Driving constraints") {
                    Stepper(value: $trip.drivingConstraints.maxKmPerDay, in: 100...1000, step: 25) {
                        HStack {
                            Text("Max km/day")
                            Spacer()
                            Text("\(trip.drivingConstraints.maxKmPerDay)")
                        }
                    }
                    Toggle("Avoid night driving", isOn: $trip.drivingConstraints.avoidNightDriving)
                    Stepper(value: $trip.drivingConstraints.breakEveryHours, in: 1...6, step: 1) {
                        HStack {
                            Text("Break every")
                            Spacer()
                            Text("\(trip.drivingConstraints.breakEveryHours) hrs")
                        }
                    }
                    Stepper(value: $trip.drivingConstraints.breakDurationMinutes, in: 5...60, step: 5) {
                        HStack {
                            Text("Break duration")
                            Spacer()
                            Text("\(trip.drivingConstraints.breakDurationMinutes) min")
                        }
                    }
                }

                Section("Family profile") {
                    Stepper(value: $trip.familyProfile.adults, in: 1...8, step: 1) {
                        HStack {
                            Text("Adults")
                            Spacer()
                            Text("\(trip.familyProfile.adults)")
                        }
                    }

                    ForEach($trip.familyProfile.kids) { $kid in
                        KidEditorRow(kid: $kid)
                    }
                    .onDelete { offsets in
                        trip.familyProfile.kids.remove(atOffsets: offsets)
                    }

                    Button("Add kid") {
                        trip.familyProfile.kids.append(Kid(name: "Kid", ageMonths: 24))
                    }
                }

                Section("Cost preferences") {
                    Picker("Food type", selection: $trip.costPreferences.foodType) {
                        ForEach(FoodType.allCases) { food in
                            Text(food.rawValue.capitalized).tag(food)
                        }
                    }
                    Stepper(value: $trip.costPreferences.dailyFoodBudget, in: 500...10000, step: 250) {
                        HStack {
                            Text("Daily food budget")
                            Spacer()
                            Text("\(trip.costPreferences.dailyFoodBudget)")
                        }
                    }
                    Stepper(value: $trip.costPreferences.lodgingBudget, in: 500...15000, step: 500) {
                        HStack {
                            Text("Lodging budget")
                            Spacer()
                            Text("\(trip.costPreferences.lodgingBudget)")
                        }
                    }
                }

                Section("Milestones") {
                    ForEach($trip.milestones) { $milestone in
                        NavigationLink {
                            MilestoneEditorView(milestone: $milestone, allowCustomType: trip.isProUser)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(milestone.name.isEmpty ? "Untitled" : milestone.name)
                                Text(milestone.type.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        trip.milestones.remove(atOffsets: offsets)
                    }
                    .onMove { source, destination in
                        trip.milestones.move(fromOffsets: source, toOffset: destination)
                    }

                    Button("Add milestone") {
                        trip.milestones.append(
                            Milestone(type: .standard(.other), name: "", mustDo: false, timeWindow: nil, notes: nil)
                        )
                    }
                }

                Section("Account") {
                    Toggle("Pro features enabled", isOn: $trip.isProUser)
                }
            }
            .navigationTitle("Trip inputs")
            .toolbar {
                EditButton()
            }
        }
    }
}

struct KidEditorRow: View {
    @Binding var kid: Kid

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Kid name", text: $kid.name)
            Stepper(value: $kid.ageMonths, in: 0...216, step: 6) {
                HStack {
                    Text("Age")
                    Spacer()
                    Text(ageLabel)
                }
            }
        }
    }

    private var ageLabel: String {
        if kid.ageMonths < 12 {
            return "\(kid.ageMonths) mo"
        }
        let years = kid.ageMonths / 12
        let months = kid.ageMonths % 12
        if months == 0 {
            return "\(years) yr"
        }
        return "\(years) yr \(months) mo"
    }
}

#Preview {
    TripEditorView()
}
