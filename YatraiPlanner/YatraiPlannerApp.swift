//
//  YatraiPlannerApp.swift
//  YatraiPlanner
//
//  Created by Ganesh Raman on 17/01/26.
//

import SwiftUI
import SwiftData

@main
struct YatraiPlannerApp: App {
    private static var isRunningTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        if environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
        return ProcessInfo.processInfo.arguments.contains("UITEST_MODE")
    }

    private static var shouldDisableCloudKit: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return FileManager.default.ubiquityIdentityToken == nil
        #endif
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: shouldDisableCloudKit ? .none : .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modifier(ModelContainerModifier(container: Self.isRunningTests ? nil : Self.makeModelContainer()))
        }
    }
}

private struct ModelContainerModifier: ViewModifier {
    let container: ModelContainer?

    func body(content: Content) -> some View {
        if let container {
            content.modelContainer(container)
        } else {
            content
        }
    }
}
