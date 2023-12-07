//
//  PreviewDependencies.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
private var sharedModelContainer: ModelContainer = {
    let schema = Schema(PersistenceSchema.models)
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

@MainActor
private var preferences = Preferences()

@MainActor
private var sessionManager = MCSessionManager()

@MainActor
var contentViewPreview: some View = ContentView().preferredColorScheme(preferences.isDarkMode ? .dark : .light)
    .environmentObject(preferences)
    .environmentObject(SessionViewModel(sessionManager: sessionManager, preferences: preferences))
    .modelContainer(sharedModelContainer)
