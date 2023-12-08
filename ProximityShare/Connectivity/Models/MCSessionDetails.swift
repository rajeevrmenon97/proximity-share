//
//  MCSessionDetails.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import Foundation
import MultipeerConnectivity

class MCSessionDetails {
    private static let sessionNameKey = "sessionName"
    private static let sessionIdKey = "sessionId"
    
    var id: String
    var name: String
    var leaderPeerID: MCPeerID
    
    init(name: String, leaderPeerID: MCPeerID) {
        self.id = UUID().uuidString
        self.name = name
        self.leaderPeerID = leaderPeerID
    }
    
    init(discoveryInfo: [String: String], leaderPeerID: MCPeerID) {
        self.id = discoveryInfo[Self.sessionIdKey]!
        self.name = discoveryInfo[Self.sessionNameKey]!
        self.leaderPeerID = leaderPeerID
    }
    
    func getDiscoveryInfo() -> [String: String] {
        return [
            Self.sessionIdKey: self.id,
            Self.sessionNameKey: self.name,
        ]
    }
}
