//
//  MCUser.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import Foundation

class MCUser: Codable, Identifiable {
    var id: String
    var name: String
    var aboutMe: String
    
    init(id: String, name: String, aboutMe: String) {
        self.id = id
        self.name = name
        self.aboutMe = aboutMe
    }
}
