//
//  SwishApp.swift
//  Swish
//
//  Created by Kirill Gladkov on 14/08/2026.
//

import SwiftData
import SwiftUI

@main
struct SwishApp: App {
    private let modelContainer: ModelContainer = {
        do {
            return try AppModelContainer.make()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
