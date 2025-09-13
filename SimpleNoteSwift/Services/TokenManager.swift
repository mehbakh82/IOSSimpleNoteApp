//
//  TokenManager.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation
import Combine

/**
 * TokenManager - JWT Token Management Service
 * 
 * Manages JWT access and refresh tokens for user authentication.
 * Provides reactive authentication state updates and secure token storage.
 * 
 * Features:
 * - Secure token storage using UserDefaults
 * - Automatic token expiry tracking
 * - Reactive authentication state management
 * - Token refresh capability
 * - Singleton pattern for app-wide access
 * 
 * Security Notes:
 * - Tokens are stored in UserDefaults (consider Keychain for production)
 * - Access tokens expire after 1 hour
 * - Refresh tokens are used for automatic token renewal
 */
class TokenManager: ObservableObject {
    /// Shared singleton instance
    static let shared = TokenManager()
    
    /// Published authentication state for reactive UI updates
    @Published var isAuthenticated = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let tokenExpiryKey = "token_expiry"
    
    /// Private initializer for singleton pattern
    private init() {
        isAuthenticated = getAccessToken() != nil
    }
    
    // MARK: - Token Management
    
    /// Saves both access and refresh tokens with expiry tracking
    /// - Parameters:
    ///   - access: JWT access token for API authentication
    ///   - refresh: JWT refresh token for token renewal
    func saveTokens(access: String, refresh: String) {
        userDefaults.set(access, forKey: accessTokenKey)
        userDefaults.set(refresh, forKey: refreshTokenKey)
        userDefaults.set(Date().addingTimeInterval(3600), forKey: tokenExpiryKey) // 1 hour expiry
        isAuthenticated = true
    }
    
    /// Saves a new access token (typically after refresh)
    /// - Parameter token: New JWT access token
    func saveAccessToken(_ token: String) {
        userDefaults.set(token, forKey: accessTokenKey)
        userDefaults.set(Date().addingTimeInterval(3600), forKey: tokenExpiryKey)
        isAuthenticated = true
    }
    
    /// Retrieves the current access token
    /// - Returns: Access token string if available, nil otherwise
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: accessTokenKey)
    }
    
    /// Retrieves the current refresh token
    /// - Returns: Refresh token string if available, nil otherwise
    func getRefreshToken() -> String? {
        return userDefaults.string(forKey: refreshTokenKey)
    }
    
    /// Checks if the current access token has expired
    /// - Returns: True if token is expired or missing, false otherwise
    func isTokenExpired() -> Bool {
        guard let expiryDate = userDefaults.object(forKey: tokenExpiryKey) as? Date else {
            return true
        }
        return Date() >= expiryDate
    }
    
    /// Clears all stored tokens and updates authentication state
    func clearTokens() {
        userDefaults.removeObject(forKey: accessTokenKey)
        userDefaults.removeObject(forKey: refreshTokenKey)
        userDefaults.removeObject(forKey: tokenExpiryKey)
        isAuthenticated = false
    }
    
    /// Determines if token refresh is needed
    /// - Returns: True if access token is expired but refresh token is available
    func needsRefresh() -> Bool {
        return isTokenExpired() && getRefreshToken() != nil
    }
}
