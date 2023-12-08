//
//  HomeView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @EnvironmentObject private var preferences: Preferences
    
    @State var newSessionNameTextField = ""
    @State var showNewSessionAlert = false
    @State var showSessionSearch = false
    
    @Query var sessions: [SharingSession]
    
    var body: some View {
        NavigationStack(path: $sessionViewModel.navigationPath) {
            VStack {
                List {
                    ForEach(sessions, id: \.id) { session in
                        SessionListItem(session)
                            .overlay {
                                NavigationLink("", value: session.id)
                                    .opacity(0)
                            }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationDestination(for: String.self) { id in
                    SessionView(session: self.sessions.first(where: {$0.id == id})!)
                }
            }
            .alert("Host Session", isPresented: $showNewSessionAlert) {
                TextField("Session name", text: $newSessionNameTextField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Create Chat", action: {
                    if !newSessionNameTextField.isEmpty {
                        sessionViewModel.startNewSession(newSessionNameTextField)
                    }
                    showNewSessionAlert = false
                })
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showSessionSearch, content: {
                SessionSearchView()
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Edit")
                        .foregroundStyle(.blue)
                }
                ToolbarItem(placement: .principal) {
                    Text("Sessions")
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu(content: {
                        Button("Host", action: {
                            newSessionNameTextField = ""
                            showNewSessionAlert = true
                        })
                        Button("Join", action: {
                            sessionViewModel.startLookingForSessions()
                            showSessionSearch = true
                        })
                    }, label: {Label("", systemImage: "plus")})
                }
            }
        }
    }
}

#Preview {
    contentViewPreview
}
