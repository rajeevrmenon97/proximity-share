//
//  SessionInfoView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI

struct SessionInfoView: View {
    @Bindable var session: SharingSession
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        Form {
            Section {
                HStack{
                    Spacer()
                    VStack {
                        DisplayPicture(name: session.name, size: 75)
                        Text("\(session.name)")
                            .font(.title)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            if session.id == sessionViewModel.activeSessionID && sessionViewModel.isLeader() {
                Section("Join Requests") {
                    ForEach(sessionViewModel.joinRequestUsers) { user in
                        HStack {
                            DisplayPicture(name: user.name, size: 15, font: .caption)
                            Text(user.name)
                            Spacer()
                            Button("Accept") {
                                withAnimation {
                                    self.sessionViewModel.acceptInvite(user: user)
                                }
                            }
                            .foregroundStyle(Color.green)
                            .buttonStyle(.bordered)
                            Button("Reject") {
                                withAnimation {
                                    self.sessionViewModel.rejectInvite(user: user)
                                }
                            }
                            .foregroundStyle(Color.red)
                            .buttonStyle(.bordered)
                        }
                    }
                    if sessionViewModel.joinRequestUsers.isEmpty {
                        Text("No pending requests")
                    }
                }
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Session Info")
    }
}
