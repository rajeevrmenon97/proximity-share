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
            ZStack {
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
                        if let session = self.sessions.first(where: {$0.id == id}) {
                            SessionView(session: session)
                        }
                    }
                }
                
                if showNewSessionAlert {
                    CustomAlertView(title: "Host Session", description: "", cancelAction: {
                        toggleNewSessionAlert()
                    }, cancelActionTitle: "Cancel", primaryAction: {
                        if !newSessionNameTextField.isEmpty {
                            sessionViewModel.startNewSession(newSessionNameTextField)
                            toggleNewSessionAlert()
                        }
                    }, primaryActionTitle: "Host", customContent: VStack {
                        TextField("Session name", text: $newSessionNameTextField)
                            .textFieldStyle(.roundedBorder)
                            .padding([.horizontal, .bottom])
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    })
                }
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
                            toggleNewSessionAlert()
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
    
    func toggleNewSessionAlert() {
        withAnimation {
            showNewSessionAlert.toggle()
        }
    }
}

#Preview {
    contentViewPreview
}
