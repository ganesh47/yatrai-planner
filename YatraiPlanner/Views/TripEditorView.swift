import AuthenticationServices
import SwiftUI

private enum TripWizardStep: Int, CaseIterable, Identifiable {
    case basics
    case dates
    case vehicle
    case constraints
    case family
    case costs
    case milestones

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .basics:
            return "Trip basics"
        case .dates:
            return "Dates & times"
        case .vehicle:
            return "Vehicle"
        case .constraints:
            return "Constraints"
        case .family:
            return "Family"
        case .costs:
            return "Costs"
        case .milestones:
            return "Milestones"
        }
    }

    var shortTitle: String {
        switch self {
        case .basics:
            return "Basics"
        case .dates:
            return "Dates"
        case .vehicle:
            return "Vehicle"
        case .constraints:
            return "Limits"
        case .family:
            return "Family"
        case .costs:
            return "Costs"
        case .milestones:
            return "Milestones"
        }
    }
}

struct TripEditorView: View {
    @State private var trip: TripInput = .sample
    @StateObject private var authManager = AppleAuthManager()
    @State private var outputItinerary: Itinerary?
    @State private var isGenerating = false
    @State private var currentIndex = 0
    @State private var completedSteps: Set<TripWizardStep> = []
    @State private var showOutputs = false

    var body: some View {
        NavigationStack {
            Form {
                stepContent
            }
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if currentStep == .milestones {
                    EditButton()
                }
            }
            .safeAreaInset(edge: .bottom) {
                wizardFooter
            }
            .onChange(of: trip.isProUser) { _, _ in
                syncStepIndex()
            }
            .sheet(isPresented: $showOutputs) {
                NavigationStack {
                    OutputHubView(trip: $trip, itinerary: $outputItinerary)
                }
            }
        }
    }

    private var steps: [TripWizardStep] {
        TripWizardStep.allCases.filter { step in
            step != .milestones || trip.isProUser
        }
    }

    private var currentStep: TripWizardStep {
        steps[min(currentIndex, max(steps.count - 1, 0))]
    }

    private var isLastStep: Bool {
        currentIndex == steps.count - 1
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .basics:
            Section("Route") {
                TextField("Starting city", text: $trip.startCity)
                    .textInputAutocapitalization(.words)
                TextField("Ending city", text: $trip.endCity)
                    .textInputAutocapitalization(.words)
            }

            Section("Account") {
                Toggle("Pro features enabled", isOn: $trip.isProUser)
                if let profile = authManager.profile {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.displayName ?? "Signed in")
                            .font(.headline)
                        if let email = profile.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let role = profile.role {
                            Text("Role: \(role.capitalized)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if let error = authManager.lastError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                if !isUITestMode, authManager.profile == nil {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        Task {
                            do {
                                switch result {
                                case .success(let authorization):
                                    try await authManager.handleAuthorization(authorization)
                                    trip.isProUser = true
                                case .failure(let error):
                                    authManager.handleAuthorizationError(error)
                                }
                            } catch {
                                // Error already surfaced from auth manager.
                            }
                        }
                    }
                    .frame(height: 44)
                    if shouldShowSignInHint {
                        Text("Sign in with Apple may fail on Simulator without iCloud. Open Settings → Apple ID to sign in, or use a real device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case .dates:
            Section("Trip dates") {
                DatePicker("Start", selection: $trip.startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End", selection: $trip.endDate, displayedComponents: [.date, .hourAndMinute])
            }
        case .vehicle:
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
        case .constraints:
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
        case .family:
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
        case .costs:
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
        case .milestones:
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
        }
    }

    private var wizardFooter: some View {
        VStack(spacing: 12) {
            Divider()
            HStack {
                Button("Back") {
                    goBack()
                }
                .disabled(currentIndex == 0)

                Spacer()

                if isLastStep {
                    Button(isGenerating ? "Generating…" : "Generate Itinerary") {
                        Task { await generateItinerary() }
                    }
                    .disabled(isGenerating)
                } else {
                    Button("Next") {
                        goNext()
                    }
                }
            }
            .padding(.horizontal, 16)

            BreadcrumbBar(
                steps: steps,
                currentStep: currentStep,
                completedSteps: completedSteps,
                onSelect: { step in
                    goToStep(step)
                }
            )
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private func goNext() {
        completedSteps.insert(currentStep)
        currentIndex = min(currentIndex + 1, steps.count - 1)
    }

    private func goBack() {
        currentIndex = max(currentIndex - 1, 0)
    }

    private func goToStep(_ step: TripWizardStep) {
        guard let index = steps.firstIndex(of: step) else { return }
        if completedSteps.contains(step) || index <= currentIndex {
            currentIndex = index
        }
    }

    private func syncStepIndex() {
        if currentIndex >= steps.count {
            currentIndex = max(steps.count - 1, 0)
        }
        completedSteps = completedSteps.filter { steps.contains($0) }
    }

    private func generateItinerary() async {
        isGenerating = true
        let service = ItineraryService(
            client: NetworkItineraryClient(baseURL: AppConfig.workerBaseURL),
            tokenProvider: tokenProvider
        )
        let itinerary = await service.generateItinerary(for: trip)
        outputItinerary = itinerary
        isGenerating = false
        showOutputs = true
    }

    private var isUITestMode: Bool {
        ProcessInfo.processInfo.arguments.contains("UITEST_MODE")
    }

    private var shouldShowSignInHint: Bool {
        #if targetEnvironment(simulator)
        return FileManager.default.ubiquityIdentityToken == nil
        #else
        return false
        #endif
    }

    private var tokenProvider: TokenProviding {
        isUITestMode ? AnonymousTokenProvider() : authManager
    }
}

private struct BreadcrumbBar: View {
    let steps: [TripWizardStep]
    let currentStep: TripWizardStep
    let completedSteps: Set<TripWizardStep>
    let onSelect: (TripWizardStep) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(steps) { step in
                    let isCurrent = step == currentStep
                    let isCompleted = completedSteps.contains(step)
                    Button {
                        onSelect(step)
                    } label: {
                        Text(step.shortTitle)
                            .font(.footnote.weight(isCurrent ? .semibold : .regular))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(isCurrent ? Color.accentColor.opacity(0.15) : Color.clear)
                            .clipShape(Capsule())
                    }
                    .accessibilityIdentifier("breadcrumb-\(step.shortTitle)")
                    .disabled(!isCompleted && !isCurrent)
                }
            }
            .padding(.vertical, 2)
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
