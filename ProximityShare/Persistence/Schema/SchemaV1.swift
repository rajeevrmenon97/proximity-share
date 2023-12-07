//
//  SchemaV1.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation
import SwiftData

typealias PersistenceSchema = SchemaV1
typealias SharingSession = SchemaV1.SharingSession
typealias User = SchemaV1.User
typealias SharingSessionEvents = SchemaV1.SharingSessionEvents

enum SchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {[
        SharingSession.self, User.self, SharingSessionEvents.self
    ]}
    
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    @Model
    final class SharingSession {
        @Attribute(.unique) let id: String
        var name: String
        
        @Transient var isLeader: Bool = false
        @Transient var isActive: Bool = false
        
        init(id: String, name: String, isLeader: Bool = false, isActive: Bool = false) {
            self.id = id
            self.name = name
            self.isLeader = isLeader
            self.isActive = isActive
        }
        
        convenience init(name: String, isLeader: Bool = false, isActive: Bool = false) {
            self.init(id: UUID().uuidString, name: name, isLeader: isLeader, isActive: isActive)
        }
    }
    
    @Model
    final class User {
        @Attribute(.unique) let id: String
        var name: String
        var aboutMe: String
        
        init(id: String, name: String, aboutMe: String) {
            self.id = id
            self.name = name
            self.aboutMe = aboutMe
        }
    }
    
    @Model
    final class SharingSessionEvents {
        enum EventType: Int, Codable {
            case message = 0
        }
        
        enum ContentType: Int, Codable {
            case message = 0
        }
        
        @Attribute(.unique) var id: String
        @Relationship(deleteRule: .cascade) var user: User
        @Relationship(deleteRule: .cascade) var session: SharingSession
        var type: EventType
        var contentType: ContentType
        var content: String
        var timestamp: Date
        
        init(id: String, type: EventType, user: User, session: SharingSession, contentType: ContentType, content: String, timestamp: Date) {
            self.id = id
            self.type = type
            self.user = user
            self.session = session
            self.contentType = contentType
            self.content = content
            self.timestamp = timestamp
        }
        
        convenience init(id: String, type: EventType, user: User, session: SharingSession, contentType: ContentType, content: String) {
            self.init(id: id, type: type,
                user: user, session: session,
                contentType: contentType, content: content,
                timestamp: Date())
        }
    }
    
}
