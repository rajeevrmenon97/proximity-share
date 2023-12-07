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
                            //TODO: Send invite
                        })
                        .foregroundColor(.primary)
                    }
                }
                .blur(radius: false ? 20 : 0)
                
                if sessionViewModel.availableSessions.isEmpty || false {
                    VStack {
                        ProgressView(false ? "Waiting for invitation response": "Looking for nearby sessions")
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
