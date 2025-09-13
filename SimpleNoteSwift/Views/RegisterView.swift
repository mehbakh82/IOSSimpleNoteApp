//
//  RegisterView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        password == confirmPassword &&
        password.count >= 8
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Join us and start taking notes")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        // First Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your first name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Last Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your last name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Choose a username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Create a password", text: $password)
                                } else {
                                    SecureField("Create a password", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Text(showPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !password.isEmpty && password.count < 8 {
                                Text("Password must be at least 8 characters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Text(showConfirmPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Register Button
                    Button(action: {
                        authViewModel.register(
                            username: username,
                            email: email,
                            password: password,
                            firstName: firstName,
                            lastName: lastName
                        )
                    }) {
                        HStack {
                            Text("Register")
                                .fontWeight(.medium)
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(25)
                    }
                    .disabled(!isFormValid || authViewModel.authState == .loading)
                    
                    // Error Message
                    if case .error(let message) = authViewModel.authState {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Success Message
                    if case .success = authViewModel.authState {
                        VStack(spacing: 12) {
                            Text("Account created successfully!")
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Button("Go to Login") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                        }
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
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
