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

@MainActor
class SessionViewModel: ObservableObject {
    @Published var navigationPath = [String]()
    @Published var availableSessions = [MCSessionDetails]()
    @Published var isInviteSent = false
    @Published var joinRequestUsers = [MCUser]()
    @Published var activeSession: SharingSession?
    
    private var sessionManager: MCSessionManager
    private var preferences: Preferences
    private var modelContext: ModelContext
    
    private var cancellables: Set<AnyCancellable> = []
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ProximtyShare", category: "SessionViewModel")
    
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
                self.availableSessions.append(sessionDetails)
                self.logger.debug("Session found: \(sessionDetails.name)")
            }
        case .lostPeer:
            if let sessionDetails = eventUpdate.sessionDetails, let index = self.availableSessions.firstIndex(where: {$0.id == sessionDetails.id}) {
                self.availableSessions.remove(at: index)
                self.logger.debug("Session lost: \(sessionDetails.name)")
            }
        case .receivedInvite:
            if let user = eventUpdate.user {
                self.joinRequestUsers.append(user)
                self.logger.debug("Received join request from \(user.name)")
            }
        case .inviteExpired:
            if let user = eventUpdate.user, let index = self.joinRequestUsers.firstIndex(where: {$0.id == user.id}) {
                self.joinRequestUsers.remove(at: index)
                self.logger.debug("Join request from \(user.name) expired")
            }
        case .inviteRejected:
            self.isInviteSent = false
        case .joinedSession:
            if let sessionDetails = eventUpdate.sessionDetails {
                self.stopLookingForSessions()
                self.addSession(sessionDetails: sessionDetails)
            }
        case .leftSession:
            self.logger.debug("Disconnected from session")
            self.activeSession = nil
        case .userUpdate:
            if let user = eventUpdate.user {
                self.modelContext.insert(User(id: user.id, name: user.name, aboutMe: user.aboutMe))
                self.logger.debug("Updated user info for \(user.name)")
            }
        case .message:
            if let user = eventUpdate.user, let eventID = eventUpdate.id, let content = eventUpdate.content, let session = self.activeSession {
                let event = SharingSessionEvent(
                    id: eventID,
                    type: .message,
                    user: nil,
                    session: nil,
                    contentType: .message,
                    content: content,
                    timestamp: Date())
                self.addEvent(event, session: session, userID: user.id)
            }
        case .startedReceivingResource:
            if let user = eventUpdate.user, let id = eventUpdate.id, let session = self.activeSession, let contentType = eventUpdate.contentType {
                let event = SharingSessionEvent(
                    id: id,
                    type: .message,
                    user: nil,
                    session: nil,
                    contentType: contentType,
                    content: "",
                    timestamp: Date())
                self.addEvent(event, session: session, userID: user.id)
            }
        case .finishedReceivingResource:
            if let data = eventUpdate.data, let id = eventUpdate.id, let event = self.getEvent(id) {
                event.attachment = data
            }
        }
    }
    
    func getEvent(_ id: String) -> SharingSessionEvent? {
        do {
            let result = try self.modelContext.fetch(FetchDescriptor<SharingSessionEvent>(predicate: #Predicate{$0.id == id}))
            return result.first
        } catch {
            self.logger.error("Error while fetching event: \(String(describing: error))")
        }
        return nil
    }
    
    func getSession(_ id: String) -> SharingSession? {
        do {
            let result = try self.modelContext.fetch(FetchDescriptor<SharingSession>(predicate: #Predicate{$0.id == id}))
            return result.first
        } catch {
            self.logger.error("Error while fetching session: \(String(describing: error))")
        }
        return nil
    }
    
    func addSession(sessionDetails: MCSessionDetails) {
        var session: SharingSession
        if let existingSession = self.getSession(sessionDetails.id) {
            session = existingSession
        } else {
            session = SharingSession(id: sessionDetails.id, name: sessionDetails.name)
            self.modelContext.insert(session)
        }
        self.activeSession = session
        self.navigationPath.append(session.id)
    }
    
    func deleteSession(_ sessionID: String) {
        do {
            try self.modelContext.delete(model: SharingSession.self, where: #Predicate { session in
                session.id == sessionID
            })
        } catch {
            self.logger.error("Error while deleting session: \(String(describing: error))")
        }
    }
    
    func startNewSession(_ sessionName: String) {
        self.sessionManager.startAdvertising(user: MCUser(id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe), sessionName: sessionName)
        if let sessionDetails = self.sessionManager.getSessionDetails() {
            self.addSession(sessionDetails: sessionDetails)
        } else {
            logger.error("Failed to get session details after starting to advertise")
        }
    }
    
    func startLookingForSessions() {
        self.availableSessions.removeAll()
        self.sessionManager.startBrowsing(user: MCUser(
            id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe))
    }
    
    func stopLookingForSessions() {
        self.availableSessions.removeAll()
        self.sessionManager.stopBrowsing()
        self.isInviteSent = false
    }
    
    func sendInvite(peerID: MCPeerID) {
        self.sessionManager.sendInvite(to: peerID)
        self.isInviteSent = true
    }
    
    func isLeader() -> Bool {
        return self.sessionManager.isLeader()
    }
    
    func acceptInvite(user: MCUser) {
        self.sessionManager.acceptInvite(user: user)
        self.joinRequestUsers.removeAll { u in
            u.id == user.id
        }
    }
    
    func rejectInvite(user: MCUser) {
        self.sessionManager.rejectInvite(user: user)
        self.joinRequestUsers.removeAll { u in
            u.id == user.id
        }
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
    
    func sendMessage(_ content: String) {
        if let eventID = self.sessionManager.sendMessage(content), let session = self.activeSession {
            let event = SharingSessionEvent(
                id: eventID,
                type: .message,
                user: nil,
                session: nil,
                contentType: .message,
                content: content,
                timestamp: Date())
            self.addEvent(event, session: session, userID: preferences.userID)
        }
    }
    
    func sendImage(_ data: Data) {
        if let session = self.activeSession, let id = self.sessionManager.sendImage(data) {
            let event = SharingSessionEvent(
                id: id,
                type: .message,
                user: nil,
                session: nil,
                contentType: .image,
                content: "",
                timestamp: Date())
            event.attachment = data
            self.addEvent(event, session: session, userID: preferences.userID)
        }
    }
    
    func deleteData() {
        do {
            self.sessionManager.resetSession()
            self.navigationPath.removeAll()
            try modelContext.delete(model: SharingSessionEvent.self)
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: SharingSession.self)
            let user = User(id: preferences.userID, name: preferences.userDisplayName, aboutMe: preferences.userAboutMe)
            modelContext.insert(user)
        } catch {
            logger.error("Error while deleting data: \(String(describing: error))")
        }
    }
}
