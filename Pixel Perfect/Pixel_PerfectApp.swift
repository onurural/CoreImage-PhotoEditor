//
//  Pixel_PerfectApp.swift
//  Pixel Perfect
//
//  Created by Onur Ural on 5.02.2023.
//

import SwiftUI

@main
struct Pixel_PerfectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
