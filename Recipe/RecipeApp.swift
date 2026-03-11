//
//  RecipeApp.swift
//  Recipe
//
//  Created by Владимир Косачев on 11.03.2026.
//

import SwiftUI
import CoreData

@main
struct RecipeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
