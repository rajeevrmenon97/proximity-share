//
//  SettingsView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI
import os

struct SettingsView: View {
    
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @Environment(\.modelContext) private var modelContext
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsView")
    
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
                        deleteData()
                    }, label: {
                        Label("Delete all data", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    })
                }
            }
            .navigationTitle("Settings")
        }
        
    }
    
    func deleteData() {
        do {
            sessionViewModel.navigationPath.removeAll()
            try modelContext.delete(model: SharingSessionEvent.self)
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: SharingSession.self)
            let user = User(id: preferences.userID,
                            name: preferences.userDisplayName,
                            aboutMe: preferences.userAboutMe)
            modelContext.insert(user)
            
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("attachments")
            let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil,  options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            logger.error("Error while deleting data: \(String(describing: error))")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Preferences())
}

