//
//  SessionSearchView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI

struct SessionSearchView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(sessionViewModel.availableSessions, id: \.id) { session in
                        Button(session.name, action: {
                            sessionViewModel.sendInvite(peerID: session.leaderPeerID)
                        })
                        .disabled(sessionViewModel.isInviteSent)
                        .foregroundColor(.primary)
                    }
                }
                .blur(radius: sessionViewModel.isInviteSent ? 20 : 0)
                
                if sessionViewModel.availableSessions.isEmpty || sessionViewModel.isInviteSent {
                    VStack {
                        ProgressView(sessionViewModel.isInviteSent ? "Waiting for invitation response": "Looking for nearby sessions")
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                }
            }
            .toolbar {
                Button("Cancel") {
                    sessionViewModel.stopLookingForSessions()
                    dismiss()
                }
            }
            .navigationTitle("Join chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    contentViewPreview
}
