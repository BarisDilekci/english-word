//
//  WordManager.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import Foundation
import CoreData

final class WordDataManager {
    static let shared = WordDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "EnglishWord")// Model adınızı buraya yazın
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
