//
//  SettingsView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var preferences: Preferences
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack{
                        Spacer()
                        VStack {
                            DisplayPicture(name: preferences.userDisplayName, size: 75)
                            Text("\(preferences.userDisplayName)")
                                .font(.title)
                                .overlay(
                                    NavigationLink("", destination: ProfileView(isEditable: true))
                                        .opacity(0)
                                )
                        }
                        Spacer()
                    }
                }
                
                Section("Appearance") {
                    Toggle(isOn: $preferences.isDarkMode, label: {
                        Label("Dark mode", systemImage: "moon")
                            .foregroundColor(.primary)
                    })
                }
                
                Section("Data") {
                    Button(action: {
                    }, label: {
                        Label("Delete all data", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    })
                }
            }
            .navigationTitle("Settings")
        }
        
    }
}

#Preview {
    SettingsView()
        .environmentObject(Preferences())
}

