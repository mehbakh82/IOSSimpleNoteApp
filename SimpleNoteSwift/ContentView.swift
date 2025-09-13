//
//  ContentView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

/**
 * ContentView - Root view controller
 * 
 * Manages the main navigation flow between authenticated and unauthenticated states.
 * Automatically switches between login screen and notes list based on authentication status.
 * 
 * Features:
 * - Reactive authentication state management
 * - Automatic view switching based on login status
 * - Seamless user experience with persistent sessions
 */
struct ContentView: View {
    /// Token manager for authentication state tracking
    @StateObject private var tokenManager = TokenManager.shared
    
    var body: some View {
        Group {
            if tokenManager.isAuthenticated {
                NotesListView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            // Authentication state is automatically managed by TokenManager
            // No additional logic needed here as the view will reactively update
        }
    }
}

#Preview {
    ContentView()
}
