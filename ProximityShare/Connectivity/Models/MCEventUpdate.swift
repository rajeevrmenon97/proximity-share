//
//  MCEventUpdate.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation
import MultipeerConnectivity

class MCEventUpdate {
    enum MCEventUpdateType {
        case foundPeer
        case lostPeer
        case receivedInvite
        case inviteExpired
        case joinedSession
        case leftSession
        case inviteRejected
        case userUpdate
        case message
    }
    
    var type: MCEventUpdateType
    
    var sessionDetails: MCSessionDetails?
    
    init(sessionDetails: MCSessionDetails, lost: Bool = false) {
        self.type = lost ? .lostPeer : .foundPeer
        self.sessionDetails = sessionDetails
    }
    
    init(joinedSession: MCSessionDetails, disconnect: Bool = false) {
        self.type = disconnect ? .leftSession : .joinedSession
        self.sessionDetails = joinedSession
    }
    
    var user: MCUser?
    
    init(invite: MCSessionInvite, expired: Bool = false) {
        self.type = expired ? .inviteExpired : .receivedInvite
        self.user = invite.user
    }
    
    init(userUpdate: MCUser) {
        self.type = .userUpdate
        self.user = userUpdate
    }
    
    init(type: MCEventUpdateType) {
        self.type = type
    }
    
    var id: String?
    var content: String?
    init(id: String, message: String, userID: String) {
        self.type = .message
        self.id = id
        self.user = MCUser(id: userID, name: "", aboutMe: "")
        self.content = message
    }
}
