//
//  HomeView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI
import SwiftData
import AlertToast

struct HomeView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @EnvironmentObject private var preferences: Preferences
    
    @State var newSessionNameTextField = ""
    @State var showNewSessionAlert = false
    @State var showSessionSearch = false
    @State var editMode = EditMode.inactive
    
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
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                sessionViewModel.deleteSession(sessions[index].id)
                            }
                        })
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
                
                if sessions.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "wifi")
                            .font(.system(size: 200))
                        Text("No sessions")
                            .padding()
                        Text("Select + to start a new session")
                        Spacer()
                    }
                    .opacity(0.3)
                }
            }
            .sheet(isPresented: $showSessionSearch, content: {
                SessionSearchView()
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
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
            .environment(\.editMode, $editMode)
        }
        .toast(isPresenting: $sessionViewModel.showToast, duration: 2, tapToDismiss: true, alert: {
            AlertToast(
                displayMode: .banner(.pop),
                type: sessionViewModel.isToastError ? .error(Color.red) : .systemImage("info.circle", .primary),
                title: sessionViewModel.toastMessage,
                style: .style(titleFont: .body))
        })
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
