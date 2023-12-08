//
//  MCEventUpdate.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation
import MultipeerConnectivity

class MCEventUpdate {
    enum MCEventType {
        case foundPeer
        case lostPeer
        case receivedInvite
        case inviteExpired
        case joinedSession
        case leftSession
        case inviteRejected
    }
    
    var type: MCEventType
    
    var sessionDetails: MCSessionDetails?
    init(sessionDetails: MCSessionDetails, lost: Bool = false) {
        self.type = lost ? .lostPeer : .foundPeer
        self.sessionDetails = sessionDetails
    }
    
    init(joinedSession: MCSessionDetails, disconnect: Bool = false) {
        self.type = disconnect ? .leftSession : .joinedSession
        self.sessionDetails = joinedSession
    }
    
    var inviteUser: MCUser?
    init(invite: MCSessionInvite, expired: Bool = false) {
        self.type = expired ? .inviteExpired : .receivedInvite
        self.inviteUser = invite.user
    }
    
    init(type: MCEventType) {
        self.type = type
    }
}
