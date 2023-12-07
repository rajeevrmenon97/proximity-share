//
//  ProfileView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

struct ProfileView: View {
    
    private var isFirstTimeLaunch = false
    private var isEditable = false
    
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.modelContext) private var modelContext
    
    @State private var displayNameTextField: String = ""
    @State private var aboutMeTextField: String = ""
    
    init(isFirstTimeLaunch: Bool = false) {
        self.isFirstTimeLaunch = isFirstTimeLaunch
        self.isEditable = isFirstTimeLaunch
    }
    
    init(isEditable: Bool) {
        self.isEditable = isEditable
    }
    
    var body: some View {
        Form {
            if isFirstTimeLaunch {
                HStack {
                    Spacer()
                    Text("Proximity Share")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .bold()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            
            HStack {
                Spacer()
                DisplayPicture(name: displayNameTextField, size: 75)
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            Section(header: Text("Name"), content: {
                TextField("Your Name", text: $displayNameTextField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(!isEditable)
            })
            
            Section(header: Text("About"), content: {
                TextField("A line about yourself", text: $aboutMeTextField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(!isEditable)
            })
            
            if isEditable {
                HStack {
                    Spacer()
                    Button("Update", action: {
                        if !displayNameTextField.isEmpty {
                            preferences.userDisplayName = displayNameTextField
                            preferences.userAboutMe = aboutMeTextField
                            let user = User(id: preferences.userID,
                                            name: preferences.userDisplayName,
                                            aboutMe: preferences.userAboutMe)
                            modelContext.insert(user)
                            // TODO: Update display name in session?
                        }
                    })
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .onAppear {
            displayNameTextField = preferences.userDisplayName
            aboutMeTextField = preferences.userAboutMe
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(Preferences())
}
