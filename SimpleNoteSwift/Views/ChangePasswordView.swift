//
//  ChangePasswordView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI
import Combine

struct ChangePasswordView: View {
    @StateObject private var apiService = APIService()
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showOldPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Change Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Update your account password")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Old Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showOldPassword {
                                    TextField("Enter current password", text: $oldPassword)
                                } else {
                                    SecureField("Enter current password", text: $oldPassword)
                                }
                                
                                Button(action: { showOldPassword.toggle() }) {
                                    Text(showOldPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // New Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showNewPassword {
                                    TextField("Enter new password", text: $newPassword)
                                } else {
                                    SecureField("Enter new password", text: $newPassword)
                                }
                                
                                Button(action: { showNewPassword.toggle() }) {
                                    Text(showNewPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !newPassword.isEmpty && newPassword.count < 6 {
                                Text("Password must be at least 6 characters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm New Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm new password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm new password", text: $confirmPassword)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Text(showConfirmPassword ? "Hide" : "Show")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !confirmPassword.isEmpty && newPassword != confirmPassword {
                                Text("Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Change Password Button
                    Button(action: {
                        changePassword()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Text("Change Password")
                                    .fontWeight(.medium)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid && !isLoading ? Color.blue : Color.gray)
                        .cornerRadius(25)
                    }
                    .disabled(!isFormValid || isLoading)
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Success Message
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func changePassword() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        apiService.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    switch completion {
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    successMessage = "Password changed successfully!"
                    // Clear form
                    oldPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    
                    // Dismiss after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            )
            .store(in: &cancellables)
    }
}

#Preview {
    ChangePasswordView()
}
