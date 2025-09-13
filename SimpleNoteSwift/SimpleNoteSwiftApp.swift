//
//  SimpleNoteSwiftApp.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

/**
 * SimpleNoteSwiftApp - Main application entry point
 * 
 * A SwiftUI-based note-taking application with offline-first architecture.
 * Features user authentication, note management, and real-time synchronization.
 * 
 * Architecture:
 * - MVVM pattern with Combine for reactive programming
 * - Core Data for local persistence
 * - URLSession for network communication
 * - JWT token-based authentication
 */
@main
struct SimpleNoteSwiftApp: App {
    /// Core Data persistence controller for local data storage
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
