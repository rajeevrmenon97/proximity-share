//
//  ContentView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

struct ContentView: View {
    private var sessionManager = MCSessionManager.shared
    
    var body: some View {
        VStack {
            Button("Host") {
                self.sessionManager.startAdvertising(user: MCUser(id: UUID().uuidString, name: "Host", aboutMe: "About host"), sessionName: "Session")
            }
            Button("Join") {
                self.sessionManager.startBrowsing(user: MCUser(id: UUID().uuidString, name: "Peer", aboutMe: "About peer"))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
