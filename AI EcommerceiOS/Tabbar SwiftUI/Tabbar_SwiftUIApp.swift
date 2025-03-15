//
//  Tabbar_SwiftUIApp.swift
//  Tabbar SwiftUI
//
//  Created by Erikneon on 8/2/24.
//

import SwiftUI

@main
struct Tabbar_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
