//
//  LoginView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Let's Login")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("And notes your idea")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    // Input Fields
                    VStack(spacing: 24) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Text(showPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // Login Button
                    Button(action: {
                        authViewModel.login(username: username, password: password)
                    }) {
                        HStack {
                            Text("Login")
                                .fontWeight(.medium)
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .disabled(authViewModel.authState == .loading)
                    
                    // Or Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("Or")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    
                    // Register Button
                    Button(action: {
                        showingRegister = true
                    }) {
                        Text("Don't have an account? Register here")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    
                    // Error Message
                    if case .error(let message) = authViewModel.authState {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Loading Indicator
                    if authViewModel.authState == .loading {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                // Navigation will be handled by the main app
            }
        }
    }
}

#Preview {
    LoginView()
}
