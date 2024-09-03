//
//  SwipeToMatchApp.swift
//  SwipeToMatch
//
//  Created by Aditi Jain on 03/09/24.
//

import SwiftUI

@main
struct SwipeToMatchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
