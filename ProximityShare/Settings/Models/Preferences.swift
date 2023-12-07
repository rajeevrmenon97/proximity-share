//
//  Preferences.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import Foundation
import Combine

fileprivate var cancellables = [String : AnyCancellable] ()

public extension Published {
    init(wrappedValue defaultValue: Value, userDefaultsKey: String) {
        let value = UserDefaults.standard.object(forKey: userDefaultsKey) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[userDefaultsKey] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: userDefaultsKey)
        }
    }
}

class Preferences: ObservableObject {
    @Published(userDefaultsKey: "user-id") var userID: String = UUID().uuidString
    @Published(userDefaultsKey: "user-name") var userDisplayName: String = ""
    @Published(userDefaultsKey: "user-aboutme") var userAboutMe: String = ""
    @Published(userDefaultsKey: "is-dark-mode") var isDarkMode: Bool = false
}
