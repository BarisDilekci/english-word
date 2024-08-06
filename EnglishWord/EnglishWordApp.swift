//
//  EnglishWordApp.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 6.08.2024.
//

import SwiftUI

@main
struct EnglishWordApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
