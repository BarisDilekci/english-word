//
//  WordModels.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import Foundation

struct WordsResponse: Codable {
    let words: [WordModels]
}


struct WordModels: Codable, Identifiable {
    let id: Int
    let categoryId: Int
    let eng: String
    let tr: String

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId
        case eng = "ENG"
        case tr = "TR"
    }
}

