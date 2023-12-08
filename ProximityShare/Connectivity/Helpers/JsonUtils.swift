//
//  JsonUtils.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import Foundation

class JsonUtils {
    
    public static func dataEncode<T: Encodable>(_ object: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(object)
            return jsonData
        } catch {
            print("Error encoding data: \(error)")
        }
        return nil
    }
    
    public static func stringEncode<T: Encodable>(_ object: T) -> String? {
        if let jsonData = Self.dataEncode(object),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
    public static func dataDecode<T: Decodable>(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("Error decoding data: \(error)")
        }
        return nil
    }
    
    public static func stringDecode<T: Decodable>(_ jsonString: String) -> T? {
        if let data = jsonString.data(using: .utf8),
            let object: T = Self.dataDecode(data) {
            return object
        }
        return nil
    }
}
