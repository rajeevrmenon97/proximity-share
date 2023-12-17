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
    private static let inviteTimeout: TimeInterval = 30
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ProximtyShare", category: "MultiPeerSession")
    private let fileStorageHelper = FileStorageHelper()
    
    private var session: MCSession?
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    private var sessionState: MCSessionState = .notConnected
    
    private var isBrowsing = false
    private var isAdvertising = false
    
    private var peerID: MCPeerID?
    private var localUser: MCUser?
    private var sessionDetails: MCSessionDetails?
    
    private var availableSessions = [MCPeerID:MCSessionDetails]()
    private var tentativeSessionDetails: MCSessionDetails?
    private var invites = [String:MCSessionInvite]()
    private var isInviteSent = false
    
    var updates = PassthroughSubject<MCEventUpdate, Never>()
    
    deinit {
        self.resetSession()
    }
    
    // Start new session
    private func startNewSession(user: MCUser, sessionName: String = "") {
        let peerID = MCPeerID(displayName: user.id)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.peerID = peerID
        self.localUser = user
        
        var discoveryInfo: [String:String]? = nil
        if !sessionName.isEmpty {
            let sessionDetails = MCSessionDetails(name: sessionName, leaderPeerID: peerID)
            discoveryInfo = sessionDetails.getDiscoveryInfo()
            self.sessionDetails = sessionDetails
        }
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: discoveryInfo, serviceType: Self.serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        
        if let session = self.session, let serviceAdvertiser = self.serviceAdvertiser, let serviceBrowser = self.serviceBrowser {
            session.delegate = self
            serviceAdvertiser.delegate = self
            serviceBrowser.delegate = self
        } else {
            self.logger.error("Error occured while starting session: Failed to initialize session, advertiser and browser")
            self.resetSession()
        }
    }
    
    // Function to reset session
    func resetSession() {
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
            self.invites.removeAll()
            self.cancelInvite()
            logger.debug("Stopped browsing for sessions")
        }
    }
    
    func getSessionDetails() -> MCSessionDetails? {
        return sessionDetails
    }
    
    func sendInvite(to peerID: MCPeerID) {
        if let serviceBrowser = self.serviceBrowser, let session = self.session, let user = self.localUser {
            var context: Data? = nil
            if let encodedUserDetails = JsonUtils.dataEncode(user) {
                context = encodedUserDetails
            }
            if let sessionDetails = self.availableSessions[peerID] {
                serviceBrowser.invitePeer(peerID, to: session, withContext: context, timeout: Self.inviteTimeout)
                self.tentativeSessionDetails = sessionDetails
                self.isInviteSent = true
                logger.debug("Sent invite to \(peerID.displayName)")
            }
        }
    }
    
    func cancelInvite() {
        self.tentativeSessionDetails = nil
        self.isInviteSent = false
    }
    
    func isLeader() -> Bool {
        if let peerID = self.peerID, let sessionDetails = self.sessionDetails {
            return peerID == sessionDetails.leaderPeerID
        }
        return false
    }
    
    func acceptInvite(user: MCUser) {
        if let invite = self.invites[user.id], let session = self.session {
            invite.invitationHandler(true, session)
        } else {
            logger.error("Invite not found for: \(user.name)")
        }
    }
    
    func rejectInvite(user: MCUser) {
        if let invite = self.invites[user.id], let session = self.session {
            invite.invitationHandler(false, session)
        } else {
            logger.error("Invite not found for: \(user.name)")
        }
    }
    
    func sendEvent(_ event: MCEvent) {
        if let session = self.session, !session.connectedPeers.isEmpty, let jsonData = JsonUtils.dataEncode(event) {
            do {
                try session.send(jsonData, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending event to peers: \(String(describing: error))")
            }
        }
    }
    
    func sendIdentity() {
        if let user = self.localUser, let encodedUserDetails = JsonUtils.stringEncode(user) {
            let event = MCEvent(
                id: UUID().uuidString,
                userID: user.id,
                type: .identity,
                contentType: .json,
                content: encodedUserDetails)
            self.sendEvent(event)
        }
    }
    
    func sendMessage(_ content: String) -> String? {
        if let user = self.localUser {
            let event = MCEvent(
                id: UUID().uuidString,
                userID: user.id,
                type: .message,
                contentType: .message,
                content: content)
            self.sendEvent(event)
            return event.id
        }
        return nil
    }
    
    func sendResource(url: URL, name: String) {
        if let session = self.session, !session.connectedPeers.isEmpty {
            for peer in session.connectedPeers {
                session.sendResource(at: url, withName: name, toPeer: peer) { error in
                    if let error = error {
                        self.logger.error("Error sending the resource \(String(describing: error))")
                    }
                    if let lastPeer = session.connectedPeers.last, lastPeer.displayName == peer.displayName {
                        self.logger.debug("Queued sending resources successfully")
                        self.fileStorageHelper.deleteFile(url: url)
                    }
                }
            }
        }
        self.logger.info("Done initiating send resource")
    }
    
    func sendImage(_ data: Data) -> String? {
        if let user = self.localUser {
            let event = MCEvent(
                id: UUID().uuidString,
                userID: user.id,
                type: .message,
                contentType: .image,
                content: "")
            if let encodedEvent = JsonUtils.stringEncode(event), let url = self.fileStorageHelper.writeDataToTemporaryFile(data: data, fileName: event.id) {
                self.sendResource(url: url, name: encodedEvent)
                return event.id
            }
        }
        return nil
    }
}

extension MCSessionManager: MCNearbyServiceAdvertiserDelegate {
    // Received an invite from user
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.debug("Received an invite from \(peerID.displayName)")
        if let data = context, let user: MCUser = JsonUtils.dataDecode(data) {
            let invite = MCSessionInvite(peerID: peerID, user: user, invitationHandler: invitationHandler)
            self.invites[user.id] = invite
            
            // Send update to view
            self.updates.send(MCEventUpdate(invite: invite))
            
            // Send invitation expiry to view after timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.inviteTimeout) {
                if self.sessionState == .notConnected && self.isInviteSent {
                    self.updates.send(MCEventUpdate(invite: invite, expired: true))
                }
            }
        }
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
        switch state {
        case .connected:
            self.sessionState = .connected
            if let tentativeSessionDetails = self.tentativeSessionDetails, !self.isLeader() && self.isInviteSent && peerID == tentativeSessionDetails.leaderPeerID {
                self.sessionDetails = tentativeSessionDetails
                self.updates.send(MCEventUpdate(joinedSession: tentativeSessionDetails))
                self.cancelInvite()
            }
            self.sendIdentity()
        case .notConnected:
            if self.sessionState == .notConnected {
                if self.isInviteSent, let sessionDetails = self.tentativeSessionDetails, peerID == sessionDetails.leaderPeerID {
                    self.cancelInvite()
                    self.updates.send(MCEventUpdate(type: .inviteRejected))
                }
            } else if self.sessionState == .connected {
                if let session = self.session, session.connectedPeers.isEmpty {
                    self.sessionState = .notConnected
                    if let sessionDetails = self.sessionDetails, !self.isLeader() {
                        self.updates.send(MCEventUpdate(joinedSession: sessionDetails, disconnect: true))
                    }
                }
            }
        default:
            break
        }
    }
    
    // Received data from peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logger.debug("Received \(data.count) bytes from \(peerID.displayName)")
        if let event: MCEvent = JsonUtils.dataDecode(data) {
            switch event.type {
            case .identity:
                if let receivedUserDetails: MCUser = JsonUtils.stringDecode(event.content) {
                    logger.debug("Received user information for \(receivedUserDetails.name)")
                    self.updates.send(MCEventUpdate(userUpdate: receivedUserDetails))
                }
            case .message:
                self.updates.send(MCEventUpdate(id: event.id, message: event.content, userID: event.userID))
            }
        }
    }
    
    // Received an input stream from peer
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        logger.debug("Received an input stream from \(peerID.displayName)")
    }
    
    // Started receiving a resource from peer
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        logger.debug("Started receiving resouce \(resourceName) from \(peerID.displayName)")
        if let event: MCEvent = JsonUtils.stringDecode(resourceName) {
            self.updates.send(MCEventUpdate(id: event.id, userID: event.userID, contentType: event.contentType, progress: progress))
        }
    }
    
    // Finished receiving a resource from peer
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        logger.debug("Finished receiving resouce \(resourceName) from \(peerID.displayName)")
        if let error = error {
            logger.error("Error finishing receiving resource \(resourceName) from \(peerID.displayName): \(String(describing: error))")
        } else {
            do {
                if let url = localURL {
                    let data = try Data(contentsOf: url)
                    if let event: MCEvent = JsonUtils.stringDecode(resourceName) {
                        self.updates.send(MCEventUpdate(id: event.id, userID: event.userID, contentType: event.contentType, data: data))
                    }
                }
            } catch {
                logger.error("Error reading resource \(resourceName) from \(peerID.displayName): \(String(describing: error))")
            }
        }
    }
    
    // Received certificate from peer
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
