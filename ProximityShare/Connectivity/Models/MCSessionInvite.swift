//
//  MCSessionInvite.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation
import MultipeerConnectivity

class MCSessionInvite {
    let peerID: MCPeerID
    let user: MCUser
    let invitationHandler: (Bool, MCSession?) -> Void
    
    init(peerID: MCPeerID, user: MCUser, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.peerID = peerID
        self.user = user
        self.invitationHandler = invitationHandler
    }
}
