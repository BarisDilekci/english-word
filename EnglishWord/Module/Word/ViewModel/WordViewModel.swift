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
    @Published var favoriteWords: Set<Int> = Set()
    
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(coreDataManager: WordManaging) {
        self.viewContext = coreDataManager.container.viewContext
        loadWords()
        loadFavoriteWords()
    }

    func loadFavoriteWords() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == true")
        
        do {
            let items = try viewContext.fetch(request)
            favoriteWords = Set(items.map { Int($0.id) })
        } catch {
            print("Favorites fetch failed: \(error)")
        }
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
        withAnimation {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let items = try viewContext.fetch(request)
                if let existingItem = items.first {
                    existingItem.isFavorite.toggle()
                } else {
                    let newItem = Item(context: viewContext)
                    newItem.timestamp = Date()
                    newItem.id = Int16(id)
                    newItem.isFavorite = true
                }
                
                try viewContext.save()
                loadFavoriteWords()
            } catch {
                print("Failed to toggle favorite: \(error)")
            }
        }
    }
}
