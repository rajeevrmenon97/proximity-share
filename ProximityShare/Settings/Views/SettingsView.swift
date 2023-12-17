//
//  SettingsView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI
import os
import SwiftData
import AlertToast

struct SettingsView: View {
    
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State var deleteDataAlert = false
    @State var showDeleteDataToast = false
    
    @Query var sessions: [SharingSession]
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ProximtyShare", category: "SettingsView")
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                            toggleDeleteDataAlert()
                        }, label: {
                            Label("Delete all data", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        })
                        .disabled(sessions.isEmpty)
                        .opacity(sessions.isEmpty ? 0.3 : 1)
                    }
                }
                
                if deleteDataAlert {
                    CustomAlertView(title: "Delete data", description: "Are you sure?", cancelAction: {
                        toggleDeleteDataAlert()
                    }, cancelActionTitle: "Cancel", primaryAction: {
                        self.sessionViewModel.deleteData()
                        toggleDeleteDataAlert()
                        showDeleteDataToast = true
                    }, primaryActionTitle: "Yes")
                }
            }
            .navigationTitle("Settings")
        }
        .toast(isPresenting: $showDeleteDataToast, duration: 1, tapToDismiss: true, alert: {
            AlertToast(
                displayMode: .alert,
                type: .complete(Color.green),
                title: "Success!",
                style: .style(titleFont: .body))
        })
        .toast(isPresenting: $sessionViewModel.showToast, duration: 2, tapToDismiss: true, alert: {
            AlertToast(
                displayMode: .banner(.pop),
                type: sessionViewModel.isToastError ? .error(Color.red) : .systemImage("info.circle", .primary),
                title: sessionViewModel.toastMessage,
                style: .style(titleFont: .body))
        })
        
    }
    
    func toggleDeleteDataAlert() {
        withAnimation {
            deleteDataAlert.toggle()
        }
    }
}

#Preview {
    contentViewPreview
}

