//
//  Persistence.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.id = Int16(i)
            newItem.isFavorite = false // Varsayılan değeri belirleyin
            
            let newWord = NewWord(context: viewContext)
            newWord.id = UUID()
            newWord.eng = "Sample English Word \(i)"
            newWord.tr = "Örnek Türkçe Kelime \(i)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "EnglishWord")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
