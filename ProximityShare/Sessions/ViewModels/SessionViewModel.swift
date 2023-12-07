//
//  SessionViewModel.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import os
import Foundation
import Combine
import SwiftData
import MultipeerConnectivity

class SessionViewModel: ObservableObject {
    @Published var navigationPath = [String]()
    @Published var availableSessions = [MCSessionDetails]()
    @Published var isInviteSent = false
    @Published var joinRequestUsers = [MCUser]()
    
    private var sessionManager: MCSessionManager
    private var preferences: Preferences
    
    private var cancellables: Set<AnyCancellable> = []
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SessionViewModel")
    
    init(sessionManager: MCSessionManager, preferences: Preferences) {
        self.sessionManager = sessionManager
        self.preferences = preferences
        self.sessionManager.updates
            .receive(on: RunLoop.main)
            .sink{self.handleUpdates($0)}
            .store(in: &cancellables)
    }
    
    func handleUpdates(_ eventUpdate: MCEventUpdate) {
        switch eventUpdate.type {
        case .foundPeer:
            if let sessionDetails = eventUpdate.sessionDetails {
                self.availableSessions.append(eventUpdate.sessionDetails!)
                self.logger.debug("Session found: \(sessionDetails.name)")
            }
        case .lostPeer:
            if let sessionDetails = eventUpdate.sessionDetails {
                self.availableSessions.remove(at: self.availableSessions.firstIndex(where: {$0.id == sessionDetails.id})!)
                self.logger.debug("Session lost: \(sessionDetails.name)")
            }
        case .receivedInvite:
            if let user = eventUpdate.inviteUser {
                self.joinRequestUsers.append(user)
                self.logger.debug("Received join request from \(user.name)")
            }
        case .inviteExpired:
            if let user = eventUpdate.inviteUser {
                self.joinRequestUsers.remove(at: self.joinRequestUsers.firstIndex(where: {$0.id == eventUpdate.inviteUser!.id})!)
                self.logger.debug("Join request from \(user.name) expired")
            }
        }
    }
    
    @MainActor
    func addSession(modelContext: ModelContext, sessionDetails: MCSessionDetails, isLeader: Bool) {
        let session = PersistenceSchema.SharingSession(id: sessionDetails.id, name: sessionDetails.name, isLeader: isLeader, isActive: true)
        modelContext.insert(session)
        self.navigationPath.append(session.id)
    }
    
    @MainActor
    func startNewSession(modelContext: ModelContext, sessionName: String) {
        self.sessionManager.startAdvertising(user: MCUser(id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe), sessionName: sessionName)
        if let sessionDetails = self.sessionManager.getSessionDetails() {
            self.addSession(modelContext: modelContext, sessionDetails: sessionDetails, isLeader: true)
        } else {
            logger.error("Failed to get session details after starting to advertise")
        }
    }
    
    @MainActor
    func startLookingForSessions() {
        self.availableSessions.removeAll()
        self.sessionManager.startBrowsing(user: MCUser(
            id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe))
    }
    
    @MainActor
    func stopLookingForSessions() {
        self.availableSessions.removeAll()
        self.sessionManager.stopBrowsing()
        self.isInviteSent = false
    }
    
    @MainActor
    func sendInvite(peerID: MCPeerID) {
        self.sessionManager.sendInvite(to: peerID)
        self.isInviteSent = true
    }
}
