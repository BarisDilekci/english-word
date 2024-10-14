//
//  EnglishWordTests.swift
//  EnglishWordTests
//
//  Created by Barış Dilekçi on 14.10.2024.
//

import XCTest
@testable import EnglishWord

final class EnglishWordTests: XCTestCase {
    
    var wordManager: MockWordDataManager!
    
    override func setUp() {
        super.setUp()
        wordManager = MockWordDataManager()
    }
    override func setUpWithError() throws {
        wordManager = nil
    }
    
    
    func test_load_favorite_words_from_data_manager() {
        XCTAssertEqual(wordManager.loadFavoriteWords(), Set<Int>())
        
        wordManager.toggleFavorite(id: 1)
        
        XCTAssertEqual(wordManager.loadFavoriteWords(), Set([1]))
    }
    
    
    func test_toggle_favorite_from_data_manager() {
        
        wordManager.toggleFavorite(id: 1)
        XCTAssertTrue(wordManager.favoriteWords.contains(1))
        
        wordManager.toggleFavorite(id: 1)
        XCTAssertFalse(wordManager.favoriteWords.contains(1))
    }
    
    func test_load_all_words() {
        wordManager.loadWords()
        
        XCTAssertEqual(wordManager.words.count, 3)
        XCTAssertEqual(wordManager.words[0].eng, "Apple")
        XCTAssertEqual(wordManager.words[1].tr, "Araba")
        XCTAssertEqual(wordManager.words[2].categoryId, 2)
    }
}
