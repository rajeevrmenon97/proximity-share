//
//  ContentView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var preferences: Preferences
    @State var selectedTab = 1
    @State var showSplashScreen = true
    
    var body: some View {
        VStack {
            if showSplashScreen {
                SplashView()
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showSplashScreen = false
                        }
                    })
            } else {
                if preferences.userDisplayName.isEmpty {
                    ProfileView(isFirstTimeLaunch: true)
                } else {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                            Label("Sessions", systemImage: "dot.radiowaves.left.and.right")
                        }.tag(1)
                        
                        SettingsView().tabItem {
                            Label("Settings", systemImage: "gear")
                        }.tag(2)
                    }
                }
            }
        }
    }
}

#Preview {
    contentViewPreview
}
