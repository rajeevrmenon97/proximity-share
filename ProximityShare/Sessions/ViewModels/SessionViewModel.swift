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

class SessionViewModel: ObservableObject {
    @Published var navigationPath = [String]()
    @Published var availableSessions = [MCSessionDetails]()
    
    private var sessionManager: MCSessionManager
    private var preferences: Preferences
    
    private var cancellables: Set<AnyCancellable> = []
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SessionViewModel")
    
    init(sessionManager: MCSessionManager, preferences: Preferences) {
        self.sessionManager = sessionManager
        self.preferences = preferences
        self.sessionManager.updates
            .receive(on: RunLoop.main)
            .sink { eventUpdate in
                switch eventUpdate.type {
                case .foundPeer:
                    self.availableSessions.append(eventUpdate.sessionDetails!)
                case .lostPeer:
                    self.availableSessions.remove(at: self.availableSessions.firstIndex(where: { sessionDetails in
                        sessionDetails.id == eventUpdate.sessionDetails!.id
                    })!)
                }
            }
            .store(in: &cancellables)
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
    }
}
