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
    }
    
    var type: MCEventType
    
    var sessionDetails: MCSessionDetails?
    
    init(sessionDetails: MCSessionDetails, lost: Bool = false) {
        self.type = lost ? .lostPeer : .foundPeer
        self.sessionDetails = sessionDetails
    }
}
