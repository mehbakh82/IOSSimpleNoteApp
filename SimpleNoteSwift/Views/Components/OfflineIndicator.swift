//
//  OfflineIndicator.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

struct OfflineIndicator: View {
    @State private var isOnline = true
    
    var body: some View {
        if !isOnline {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                
                Text("You're offline. Changes will sync when you're back online.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    VStack {
        OfflineIndicator()
        Spacer()
    }
}
