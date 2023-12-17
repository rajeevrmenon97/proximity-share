//
//  StringExtensions.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/16/23.
//

import Foundation

extension String {
    func initials() -> String {
        let words = self.components(separatedBy: " ")
        var initials = words.compactMap { $0.first }.map { String($0) }.joined()
        if initials.count > 2 {
            initials = String(initials.first!) + String(initials.last!)
        }
        return initials.uppercased()
    }
}
