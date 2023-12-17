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
    @AppStorage("is-dark-mode") var isDarkMode = false
    private var preferences: Preferences
    private var sessionManager: MCSessionManager
    private var sessionViewModel: SessionViewModel
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(PersistenceSchema.models)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        self.preferences = Preferences()
        self.sessionManager = MCSessionManager()
        self.sessionViewModel = SessionViewModel(sessionManager: self.sessionManager, preferences: self.preferences, modelContainer: sharedModelContainer)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(self.preferences)
                .environmentObject(self.sessionViewModel)
                .modelContainer(sharedModelContainer)
        }
    }
}
