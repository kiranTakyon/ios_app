//
//  CacheManager.swift
//  Ambassador Education
//
//  Created by apple on 18/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import Foundation


class CacheManager {
    func saveToCache<T: Codable>(data: T, key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func loadFromCache<T: Codable>(key: String) -> T? {
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(T.self, from: savedData) {
                return loadedData
            }
        }
        return nil
    }
}
