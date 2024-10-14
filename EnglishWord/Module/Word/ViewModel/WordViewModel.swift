//
//  WordViewModel.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import SwiftUI
import Combine
import CoreData

enum FilterOption {
    case all, favorites
}

class WordViewModel: ObservableObject {
    @Published var words: [WordModels] = []
    @Published var showMessage: Bool = false
    @Published var searchText: String = ""
    @Published var filterOption: FilterOption = .all
    @Published var favoriteWords: Set<Int> = []

    private var cancellables = Set<AnyCancellable>()
    private var wordManager: WordDataManager

    init(wordManager: WordDataManager = .shared) {
        self.wordManager = wordManager
        
        wordManager.$favoriteWords
            .receive(on: RunLoop.main)
            .assign(to: &$favoriteWords)

        loadWords()
    }

    func loadWords() {
        let response: WordsResponse = Bundle.main.decode("word.json")
        self.words = response.words
        self.showMessage = true

        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.showMessage = false
            }
            .store(in: &cancellables)
    }

    var filteredWords: [WordModels] {
        var words = self.words
        
        if !searchText.isEmpty {
            words = words.filter { $0.tr.localizedCaseInsensitiveContains(searchText) || $0.eng.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch filterOption {
        case .all:
            return words
        case .favorites:
            return words.filter { favoriteWords.contains($0.id) }
        }
    }

    func toggleFavorite(id: Int) {
        wordManager.toggleFavorite(id: id)
        favoriteWords = wordManager.favoriteWords
    }
}
