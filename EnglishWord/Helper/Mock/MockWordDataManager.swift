//
//  MockWordDataManagerg.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 14.10.2024.


class MockWordDataManager: WordManagerProtocol {
    var favoriteWords: Set<Int> = []
    var words: [WordModels] = []

    func loadFavoriteWords() -> Set<Int> {
        return favoriteWords
    }

    func toggleFavorite(id: Int) {
        if favoriteWords.contains(id) {
            favoriteWords.remove(id)
        } else {
            favoriteWords.insert(id)
        }
    }
    
    func loadWords() {
        words = [
            WordModels(id: 1, categoryId: 1, eng: "Apple", tr: "Elma"),
            WordModels(id: 2, categoryId: 1, eng: "Car", tr: "Araba"),
            WordModels(id: 3, categoryId: 2, eng: "House", tr: "Ev"),
        ]
    }
}
