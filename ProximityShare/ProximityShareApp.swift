//
//  ProximityShareApp.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI
import SwiftData

@main
struct ProximityShareApp: App {
    @StateObject private var preferences = Preferences()
    private var sessionManager = MCSessionManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(PersistenceSchema.models)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(preferences.isDarkMode ? .dark : .light)
                .environmentObject(self.preferences)
                .environmentObject(SessionViewModel(sessionManager: self.sessionManager, preferences: self.preferences, modelContainer: sharedModelContainer))
                .modelContainer(sharedModelContainer)
        }
    }
}
