//
//  NoteModel.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation

// MARK: - Note Data Models
struct APINote: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let createdAt: String
    let updatedAt: String
    let creatorName: String
    let creatorUsername: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case creatorName = "creator_name"
        case creatorUsername = "creator_username"
    }
}

struct NoteRequest: Codable {
    let title: String
    let description: String
}

struct UpdateNoteRequest: Codable {
    let title: String
    let description: String
}

// MARK: - User Data Models
struct APIUser: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else {
            return username
        }
    }
}

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case password
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    init(username: String, email: String, password: String, firstName: String, lastName: String) {
        self.username = username
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}

struct LoginResponse: Codable {
    let access: String
    let refresh: String
}

struct RegisterResponse: Codable {
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct TokenResponse: Codable {
    let access: String
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
}

struct PaginatedResponse<T: Codable>: Codable {
    let results: [T]
    let count: Int
    let next: String?
    let previous: String?
}

// MARK: - Type Aliases for API Responses
// Note: Using full model names to avoid conflicts with Core Data entities
