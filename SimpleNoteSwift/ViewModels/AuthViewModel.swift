//
//  AuthViewModel.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation
import Combine

// MARK: - Authentication State
enum AuthState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - Auth ViewModel
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .idle
    @Published var isAuthenticated = false
    
    private let apiService: APIServiceProtocol
    private let coreDataService = CoreDataService.shared
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        self.isAuthenticated = tokenManager.isAuthenticated
        
        // Listen to authentication state changes
        tokenManager.$isAuthenticated
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    func login(username: String, password: String) {
        authState = .loading
        
        apiService.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.authState = .error(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleLoginSuccess(response)
                }
            )
            .store(in: &cancellables)
    }
    
    func register(username: String, email: String, password: String, firstName: String, lastName: String) {
        authState = .loading
        
        // Trim whitespace and validate inputs
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate that all fields are not empty after trimming
        guard !trimmedUsername.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedFirstName.isEmpty,
              !trimmedLastName.isEmpty else {
            authState = .error("All fields are required")
            return
        }
        
        let request = RegisterRequest(
            username: trimmedUsername,
            email: trimmedEmail,
            password: password,
            firstName: trimmedFirstName,
            lastName: trimmedLastName
        )
        
        
        apiService.register(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.authState = .error(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.authState = .success
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        tokenManager.clearTokens()
        authState = .idle
    }
    
    func resetState() {
        authState = .idle
    }
    
    // MARK: - Private Methods
    private func handleLoginSuccess(_ response: LoginResponse) {
        tokenManager.saveTokens(access: response.access, refresh: response.refresh)
        
        // Fetch user info after successful login
        apiService.getUserInfo()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.authState = .error(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (user: APIUser) in
                    self?.coreDataService.saveUser(user)
                    self?.authState = .success
                }
            )
            .store(in: &cancellables)
    }
}
