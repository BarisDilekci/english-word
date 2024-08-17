//
//  MockWordManager.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 18.08.2024.
//

import CoreData

final class MockWordManager: WordManaging {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "EnglishWord")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription()]
        container.loadPersistentStores { _, _ in }
        return container
    }
}
