//
//  ProximityShareApp.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

@main
struct ProximityShareApp: App {
    @StateObject private var preferences = Preferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(preferences.isDarkMode ? .dark : .light)
                .environmentObject(self.preferences)
        }
    }
}
