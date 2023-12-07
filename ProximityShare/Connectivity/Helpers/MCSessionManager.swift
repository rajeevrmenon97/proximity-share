//
//  MultiPeerSessionManager.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import Foundation
import Combine
import os
import MultipeerConnectivity

class MCSessionManager: NSObject {
    private static let serviceType = "rrm-proxshare"
    public static var shared = MCSessionManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MultiPeerSession")
    
    private var session: MCSession? = nil
    private var serviceAdvertiser: MCNearbyServiceAdvertiser? = nil
    private var serviceBrowser: MCNearbyServiceBrowser? = nil
    
    private var isBrowsing = false
    private var isAdvertising = false
    
    private var peerID: MCPeerID? = nil
    private var localUser: MCUser? = nil
    private var sessionDetails: MCSessionDetails? = nil
    
    private var availableSessions = [MCPeerID:MCSessionDetails]()
    
    var updates = PassthroughSubject<MCEventUpdate, Never>()
    
    deinit {
        self.resetSession()
    }
    
    // Start new session
    private func startNewSession(user: MCUser, sessionName: String = "") {
        let peerID = MCPeerID(displayName: user.id)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.session!.delegate = self
        self.peerID = peerID
        self.localUser = user
        
        var discoveryInfo: [String:String]? = nil
        if !sessionName.isEmpty {
            let sessionDetails = MCSessionDetails(name: sessionName, leaderPeerID: peerID)
            discoveryInfo = sessionDetails.getDiscoveryInfo()
            self.sessionDetails = sessionDetails
        }
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: discoveryInfo, serviceType: Self.serviceType)
        self.serviceAdvertiser!.delegate = self
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        self.serviceBrowser!.delegate = self
    }
    
    // Function to reset session
    private func resetSession() {
        self.stopBrowsing()
        self.stopAdvertising()
        self.sessionDetails = nil
        self.peerID = nil
        self.localUser = nil
        self.session = nil
    }
    
    // Start advertising session
    func startAdvertising(user: MCUser, sessionName: String) {
        self.stopBrowsing()
        self.stopAdvertising()
        
        self.startNewSession(user: user, sessionName: sessionName)
        if let serviceAdvertiser = self.serviceAdvertiser {
            serviceAdvertiser.startAdvertisingPeer()
            self.isAdvertising = true
            logger.debug("Started advertising session \(sessionName)")
        }
    }
    
    // Stop advertising
    func stopAdvertising() {
        if self.isAdvertising, let serviceAdvertiser = self.serviceAdvertiser {
            serviceAdvertiser.stopAdvertisingPeer()
            self.isAdvertising = false
            self.serviceAdvertiser = nil
            logger.debug("Stopped advertising session")
        }
    }
    
    // Start browsing for sessions
    func startBrowsing(user: MCUser) {
        self.stopAdvertising()
        self.stopBrowsing()
        
        self.startNewSession(user: user)
        if !self.isBrowsing, let serviceBrowser = self.serviceBrowser {
            serviceBrowser.startBrowsingForPeers()
            self.isBrowsing = true
            logger.debug("Started browsing for sessions")
        }
    }
    
    // Stop browsing
    func stopBrowsing() {
        if self.isBrowsing, let serviceBrowser = self.serviceBrowser {
            serviceBrowser.stopBrowsingForPeers()
            self.isBrowsing = false
            self.serviceBrowser = nil
            self.availableSessions.removeAll()
            logger.debug("Stopped browsing for sessions")
        }
    }
    
    func getSessionDetails() -> MCSessionDetails? {
        return sessionDetails
    }
}

extension MCSessionManager: MCNearbyServiceAdvertiserDelegate {
    // Received an invite from user
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.debug("Received an invite from \(peerID.displayName)")
    }
    
    // Error while trying to start advertising session
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        logger.error("Error while starting to advertise session: \(String(describing: error))")
    }
}

extension MCSessionManager: MCNearbyServiceBrowserDelegate {
    // Found peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        logger.debug("Found peer \(peerID.displayName)")
        if let discoveryInfo = info {
            let sessionDetails = MCSessionDetails(discoveryInfo: discoveryInfo, leaderPeerID: peerID)
            self.availableSessions[peerID] = sessionDetails
            self.updates.send(MCEventUpdate(sessionDetails: sessionDetails))
        }
    }
    
    // Lost peer
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        logger.debug("Lost peer \(peerID.displayName)")
        if let sessionDetails = self.availableSessions[peerID] {
            self.availableSessions.removeValue(forKey: peerID)
            self.updates.send(MCEventUpdate(sessionDetails: sessionDetails, lost: true))
        } else {
            logger.error("Lost peer \(peerID.displayName), but not found in available peers")
        }
    }
    
    // Error while trying to start browsing for peer
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        logger.error("Error while starting to look for nearby peers: \(String(describing: error))")
    }
}

extension MCSessionManager: MCSessionDelegate {
    // Peer changed session state
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        logger.debug("Peer \(peerID.displayName) changed state to \(state.rawValue)")
    }
    
    // Received data from peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logger.debug("Received \(data.count) bytes from \(peerID.displayName)")
    }
    
    // Received an input stream from peer
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        logger.debug("Received an input stream from \(peerID.displayName)")
    }
    
    // Started receiving a resource from peer
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        logger.debug("Started receiving resouce \(resourceName) from \(peerID.displayName)")
    }
    
    // Finished receiving a resource from peer
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        logger.debug("Finished receiving resouce \(resourceName) from \(peerID.displayName)")
    }
    
    // Received certificate from peer
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
