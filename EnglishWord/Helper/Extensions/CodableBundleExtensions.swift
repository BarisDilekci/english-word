//
//  CodableBundleExtensions.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import Foundation

extension Bundle {
    func decode<T: Codable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        do {
            let loaded = try decoder.decode(T.self, from: data)
            return loaded
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error)")
        }
    }
}
