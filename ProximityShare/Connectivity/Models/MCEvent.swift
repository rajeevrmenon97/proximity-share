//
//  MCEvent.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation

enum EventType: Int, Codable {
    case message = 0
    case identity = 1
}

enum ContentType: Int, Codable {
    case message = 0
    case json = 1
    case image = 2
}

class MCEvent: Codable {
    var id: String
    var userID: String
    var type: EventType
    var contentType: ContentType
    var content: String
    
    init(id: String, userID: String, type: EventType, contentType: ContentType, content: String) {
        self.id = id
        self.userID = userID
        self.type = type
        self.contentType = contentType
        self.content = content
    }
}

