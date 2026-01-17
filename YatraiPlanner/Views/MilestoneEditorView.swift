import SwiftUI

struct MilestoneEditorView: View {
    @Binding var milestone: Milestone
    let allowCustomType: Bool

    @State private var standardType: StandardMilestoneType
    @State private var useCustomType: Bool
    @State private var customType: String
    @State private var useTimeWindow: Bool

    init(milestone: Binding<Milestone>, allowCustomType: Bool) {
        _milestone = milestone
        self.allowCustomType = allowCustomType
        switch milestone.wrappedValue.type {
        case .standard(let value):
            _standardType = State(initialValue: value)
            _useCustomType = State(initialValue: false)
            _customType = State(initialValue: "")
        case .custom(let value):
            _standardType = State(initialValue: .other)
            _useCustomType = State(initialValue: allowCustomType)
            _customType = State(initialValue: allowCustomType ? value : "")
        }
        _useTimeWindow = State(initialValue: milestone.wrappedValue.timeWindow != nil)
    }

    var body: some View {
        Form {
            Section("Type") {
                if allowCustomType {
                    Toggle("Use custom type", isOn: $useCustomType)
                }

                if useCustomType && allowCustomType {
                    TextField("Custom type", text: $customType)
                        .onChange(of: customType) { _, newValue in
                            milestone.type = .custom(newValue)
                        }
                        .onAppear {
                            milestone.type = .custom(customType)
                        }
                } else {
                    Picker("Type", selection: $standardType) {
                        ForEach(StandardMilestoneType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .onChange(of: standardType) { _, newValue in
                        milestone.type = .standard(newValue)
                    }
                    .onAppear {
                        milestone.type = .standard(standardType)
                    }
                }
            }

            Section("Details") {
                TextField("Name", text: $milestone.name)
                Toggle("Must do", isOn: $milestone.mustDo)
                Toggle("Add time window", isOn: $useTimeWindow)
                    .onChange(of: useTimeWindow) { _, newValue in
                        milestone.timeWindow = newValue ? TimeWindow(start: Date(), end: Date()) : nil
                    }

                if useTimeWindow {
                    DatePicker(
                        "Window start",
                        selection: Binding(
                            get: { milestone.timeWindow?.start ?? Date() },
                            set: { milestone.timeWindow?.start = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    DatePicker(
                        "Window end",
                        selection: Binding(
                            get: { milestone.timeWindow?.end ?? Date() },
                            set: { milestone.timeWindow?.end = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                TextField("Notes", text: Binding(
                    get: { milestone.notes ?? "" },
                    set: { milestone.notes = $0.isEmpty ? nil : $0 }
                ))
            }
        }
        .navigationTitle("Milestone")
        .onChange(of: useCustomType) { _, newValue in
            if newValue {
                milestone.type = .custom(customType)
            } else {
                milestone.type = .standard(standardType)
            }
        }
    }
}

#Preview {
    MilestoneEditorView(
        milestone: .constant(
            Milestone(type: .standard(.town), name: "Chittoor", mustDo: false, timeWindow: nil, notes: nil)
        ),
        allowCustomType: true
    )
}
