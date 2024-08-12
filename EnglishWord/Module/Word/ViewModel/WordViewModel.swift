//
//  WordViewModel.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import Foundation
import Combine

class WordViewModel: ObservableObject {
    @Published var words: [WordModels] = []
    @Published var totalWords: Int = 0
    @Published var showMessage: Bool = false


    private var cancellables = Set<AnyCancellable>()

    init() {
        loadWords()
    }

    func loadWords() {
        let response: WordsResponse = Bundle.main.decode("word.json")
        self.words = response.words
        self.totalWords = response.words.count
        self.showMessage = true

        // Mesajı 5 dakika sonra gizle
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.showMessage = false
            }
            .store(in: &cancellables)
    }
    
}
