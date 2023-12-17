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
        case startedReceivingResource
        case finishedReceivingResource
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
    var contentType: ContentType?
    var content: String?
    init(id: String, message: String, userID: String) {
        self.type = .message
        self.id = id
        self.user = MCUser(id: userID, name: "", aboutMe: "")
        self.content = message
        self.contentType = .message
    }
    
    var data: Data?
    var progress: Progress?
    
    init(id: String, userID: String, contentType: ContentType, progress: Progress) {
        self.type = .startedReceivingResource
        self.id = id
        self.user = MCUser(id: userID, name: "", aboutMe: "")
        self.contentType = contentType
        self.progress = progress
    }
    
    init(id: String, userID: String, contentType: ContentType, data: Data?) {
        self.type = .finishedReceivingResource
        self.id = id
        self.data = data
        self.user = MCUser(id: userID, name: "", aboutMe: "")
        self.contentType = contentType
    }
}
