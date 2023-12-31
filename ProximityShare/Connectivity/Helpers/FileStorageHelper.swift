//
//  FileStorageHelper.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/16/23.
//

import Foundation
import os

class FileStorageHelper {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ProximtyShare", category: "MultiPeerSession")
    
    func writeDataToTemporaryFile(data: Data, fileName: String = UUID().uuidString) -> URL? {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
            try data.write(to: url)
            return url
        } catch {
            self.logger.error("Error while writing to temporary file: \(String(describing: error))")
        }
        return nil
    }
    
    func deleteFile(url: URL) {
        let fileManager = FileManager.default
        
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } else {
                self.logger.warning("File does not exist at \(url)")
            }
        } catch {
            self.logger.error("Error deleting file: \(error)")
        }
    }
}
