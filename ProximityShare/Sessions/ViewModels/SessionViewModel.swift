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
    private var modelContext: ModelContext
    
    private var cancellables: Set<AnyCancellable> = []
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SessionViewModel")
    
    @MainActor
    init(sessionManager: MCSessionManager, preferences: Preferences, modelContainer: ModelContainer) {
        self.sessionManager = sessionManager
        self.preferences = preferences
        self.modelContext = modelContainer.mainContext
        self.sessionManager.updates
            .receive(on: RunLoop.main)
            .sink{self.handleUpdates($0)}
            .store(in: &cancellables)
        
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else { return }
        self.logger.debug("DB location: \(appSupportDir.absoluteString)")
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
    func addSession(sessionDetails: MCSessionDetails, isLeader: Bool) {
        let session = PersistenceSchema.SharingSession(id: sessionDetails.id, name: sessionDetails.name, isLeader: isLeader, isActive: true)
        self.modelContext.insert(session)
        self.navigationPath.append(session.id)
    }
    
    @MainActor
    func startNewSession(_ sessionName: String) {
        self.sessionManager.startAdvertising(user: MCUser(id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe), sessionName: sessionName)
        if let sessionDetails = self.sessionManager.getSessionDetails() {
            self.addSession(sessionDetails: sessionDetails, isLeader: true)
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
    
    func getUserDetails(_ id: String) -> User? {
        do {
            let result = try self.modelContext.fetch(FetchDescriptor<User>(predicate: #Predicate{$0.id == id}))
            return result.first
        } catch {
            self.logger.error("Error while fetching user: \(String(describing: error))")
        }
        return nil
    }
    
    func addEvent(_ event: SharingSessionEvent, session: SharingSession, userID: String) {
        if let user = self.getUserDetails(userID) {
            user.events.append(event)
            session.events.append(event)
        }
    }
    
    func sendMessage(_ content: String, session: SharingSession) {
        let event = SharingSessionEvent(
            id: UUID().uuidString,
            type: .message,
            user: nil,
            session: nil,
            contentType: .message,
            content: content,
            timestamp: Date())
        self.addEvent(event, session: session, userID: preferences.userID)
        // TODO: Send message to session
    }
}
