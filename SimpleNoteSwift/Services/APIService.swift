//
//  APIService.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation
import Combine

/**
 * APIServiceProtocol - Network service interface
 * 
 * Defines the contract for all API operations including authentication,
 * note management, and user operations. Uses Combine publishers for
 * reactive programming and error handling.
 */
protocol APIServiceProtocol {
    // MARK: - Authentication
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, Error>
    func register(request: RegisterRequest) -> AnyPublisher<RegisterResponse, Error>
    func getUserInfo() -> AnyPublisher<APIUser, Error>
    func changePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Void, Error>
    func refreshToken() -> AnyPublisher<TokenResponse, Error>
    
    // MARK: - Note Management
    func getNotes(page: Int, search: String?) -> AnyPublisher<PaginatedResponse<APINote>, Error>
    func createNote(request: NoteRequest) -> AnyPublisher<APINote, Error>
    func updateNote(id: Int, request: UpdateNoteRequest) -> AnyPublisher<APINote, Error>
    func deleteNote(id: Int) -> AnyPublisher<Void, Error>
}

/**
 * APIService - Network layer implementation
 * 
 * Handles all HTTP communication with the Django REST API backend.
 * Provides reactive Combine publishers for all network operations.
 * 
 * Features:
 * - JWT token-based authentication
 * - Automatic error handling and mapping
 * - Request/response logging (removed for production)
 * - Support for pagination and search
 * - Offline-first architecture support
 * 
 * Configuration:
 * - Base URL: http://localhost:8000/api (development)
 * - Content-Type: application/json
 * - Authentication: Bearer token in Authorization header
 */
class APIService: ObservableObject, APIServiceProtocol {
    // MARK: - Private Properties
    /// Base URL for the API server
    private let baseURL = "http://localhost:8000/api" // Local development server
    /// URLSession for HTTP requests
    private let session = URLSession.shared
    /// Combine cancellables for memory management
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        let request = LoginRequest(username: username, password: password)
        return makeRequest(endpoint: "/auth/token/", method: "POST", body: request)
    }
    
    func register(request: RegisterRequest) -> AnyPublisher<RegisterResponse, Error> {
        guard let url = URL(string: baseURL + "/auth/register/") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                
                if httpResponse.statusCode >= 400 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw APIError.httpError(httpResponse.statusCode, errorMessage)
                }
                
                return data
            }
            .decode(type: RegisterResponse.self, decoder: JSONDecoder())
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<TokenResponse, Error> {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            return Fail(error: APIError.noRefreshToken)
                .eraseToAnyPublisher()
        }
        
        let body = ["refresh": refreshToken]
        return makeRequest(endpoint: "/auth/token/refresh/", method: "POST", body: body)
    }
    
    func getUserInfo() -> AnyPublisher<APIUser, Error> {
        var request = URLRequest(url: URL(string: baseURL + "/auth/userinfo/")!)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: APIUser.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Void, Error> {
        let body = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        return makeRequest(endpoint: "/auth/change-password/", method: "POST", body: body)
            .map { (_: Data) in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Notes
    func getNotes(page: Int, search: String? = nil) -> AnyPublisher<PaginatedResponse<APINote>, Error> {
        var components: URLComponents
        
        if let search = search, !search.isEmpty {
            // Use filter endpoint for search
            components = URLComponents(string: baseURL + "/notes/filter")!
            let queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "title", value: search)
            ]
            components.queryItems = queryItems
        } else {
            // Use regular notes endpoint
            components = URLComponents(string: baseURL + "/notes/")!
            components.queryItems = [URLQueryItem(name: "page", value: String(page))]
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PaginatedResponse<APINote>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func createNote(request: NoteRequest) -> AnyPublisher<APINote, Error> {
        return makeRequest(endpoint: "/notes/", method: "POST", body: request)
    }
    
    func updateNote(id: Int, request: UpdateNoteRequest) -> AnyPublisher<APINote, Error> {
        return makeRequest(endpoint: "/notes/\(id)/", method: "PATCH", body: request)
    }
    
    func deleteNote(id: Int) -> AnyPublisher<Void, Error> {
        var request = URLRequest(url: URL(string: baseURL + "/notes/\(id)/")!)
        request.httpMethod = "DELETE"
        addAuthHeader(to: &request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                
                if httpResponse.statusCode >= 400 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw APIError.httpError(httpResponse.statusCode, errorMessage)
                }
                
                return ()
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func makeRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: String,
        body: T
    ) -> AnyPublisher<R, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
            
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                
                if httpResponse.statusCode >= 400 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw APIError.httpError(httpResponse.statusCode, errorMessage)
                }
                
                return data
            }
            .decode(type: R.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

/**
 * APIError - Network and API error types
 * 
 * Comprehensive error handling for all API operations.
 * Provides user-friendly error messages and proper error categorization.
 * 
 * Error Types:
 * - Network errors: Connection issues, timeouts
 * - HTTP errors: Server responses (4xx, 5xx)
 * - Decoding errors: JSON parsing failures
 * - Authentication errors: Token issues
 * - Validation errors: Invalid requests
 */
enum APIError: Error, LocalizedError {
    case invalidURL
    case noRefreshToken
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case invalidResponse
    case httpError(Int, String)
    
    /// User-friendly error descriptions
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noRefreshToken:
            return "No refresh token available"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message)"
        }
    }
}
