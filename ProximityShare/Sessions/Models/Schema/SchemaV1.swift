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
typealias SharingSessionEvent = SchemaV1.SharingSessionEvent

enum SchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {[
        SharingSession.self, User.self, SharingSessionEvent.self
    ]}
    
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    @Model
    final class SharingSession {
        @Attribute(.unique) let id: String
        var name: String
        var events = [SharingSessionEvent]()
        
        init(id: String, name: String) {
            self.id = id
            self.name = name
            self.events = [SharingSessionEvent]()
        }
    }
    
    @Model
    final class User {
        @Attribute(.unique) let id: String
        var name: String
        var aboutMe: String
        var events = [SharingSessionEvent]()
        
        init(id: String, name: String, aboutMe: String) {
            self.id = id
            self.name = name
            self.aboutMe = aboutMe
        }
    }
    
    @Model
    final class SharingSessionEvent {
        @Attribute(.unique) var id: String
        @Relationship(deleteRule: .cascade, inverse: \User.events)
        var user: User?
        @Relationship(deleteRule: .cascade, inverse: \SharingSession.events)
        var session: SharingSession?
        var type: EventType
        var contentType: ContentType
        var content: String
        var timestamp: Date
        
        @Transient var attachment: Data? = nil
        
        init(id: String, type: EventType, user: User?, session: SharingSession?, contentType: ContentType, content: String, timestamp: Date) {
            self.id = id
            self.type = type
            self.user = user
            self.session = session
            self.contentType = contentType
            self.content = content
            self.timestamp = timestamp
        }
    }
}
