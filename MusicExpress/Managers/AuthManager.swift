//
//  AuthManager.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        credentials = LoginCredentials(
            cookie: UserDefaults.standard.string(forKey: "cookie") ?? "",
            csrf: UserDefaults.standard.string(forKey: "csrf") ?? "",
            expired: dateFormatter.date(
                from: UserDefaults.standard.string(forKey: "expire") ?? ""
            ) ?? Date()
        )
        
     //   print(credentials.expired, credentials.cookie, credentials.csrf)
    }
    
    public func isSignedIn() -> Bool {
        if Date() < credentials.expired && credentials.cookie != "" && credentials.csrf != "" {
            return true
        }
        
        return false
    }
    
    public func getAccessToken() -> String {
        return credentials.cookie
    }
    
    public func getCSRFToken() -> String {
        return credentials.csrf
    }
    
    public func setAccessToken(credentials_: LoginCredentials) {
        credentials = credentials_

        UserDefaults.standard.setValue(credentials.csrf, forKey: "csrf")
        UserDefaults.standard.setValue(credentials.cookie, forKey: "cookie")
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        UserDefaults.standard.setValue(formatter.string(from: credentials.expired), forKey: "expire")
        
        print(credentials.expired, credentials.cookie, credentials.csrf)
    }
    
    private let dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    private var credentials: LoginCredentials
    
}
