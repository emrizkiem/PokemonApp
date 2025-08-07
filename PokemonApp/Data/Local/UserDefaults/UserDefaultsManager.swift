//
//  UserDefaultsManager.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

protocol UserDefaultsManagerProtocol {
  func set<T>(_ value: T, for key: String)
  func get<T>(_ type: T.Type, for key: String, defaultValue: T) -> T
  func remove(for key: String)
  func exists(for key: String) -> Bool
  
  var currentUserId: String? { get set }
  var isFirstLaunch: Bool { get set }
  var lastSyncDate: Date? { get set }
  var isUserLoggedIn: Bool { get set }
  
  // Extended methods for User management
  func saveCurrentUser(_ user: User)
  func getCurrentUser() -> User?
  func clearUserSession()
  func setUserSession(userId: String)
  func hasValidSession() -> Bool
}

final class UserDefaultsManager: UserDefaultsManagerProtocol {
  
  private let userDefaults = UserDefaults.standard
  
  private struct Keys {
    static let currentUserId = "pokemon_app_current_user_id"
    static let currentUserData = "pokemon_app_current_user_data"
    static let isFirstLaunch = "pokemon_app_is_first_launch"
    static let lastSyncDate = "pokemon_app_last_sync_date"
    static let isUserLoggedIn = "pokemon_app_is_user_logged_in"
    static let appVersion = "pokemon_app_version"
  }
  
  init() {
    print("⚙️ UserDefaultsManager initialized")
    
    if get(String.self, for: Keys.appVersion, defaultValue: "") != Constants.App.version {
      set(Constants.App.version, for: Keys.appVersion)
      print("⚙️ App version updated to: \(Constants.App.version)")
    }
  }
  
  // MARK: - Generic Methods
  func set<T>(_ value: T, for key: String) {
    userDefaults.set(value, forKey: key)
    userDefaults.synchronize()
    print("⚙️ UserDefaults SET: \(key) = \(value)")
  }
  
  func get<T>(_ type: T.Type, for key: String, defaultValue: T) -> T {
    let value = userDefaults.object(forKey: key) as? T ?? defaultValue
    print("⚙️ UserDefaults GET: \(key) = \(value)")
    return value
  }
  
  func remove(for key: String) {
    userDefaults.removeObject(forKey: key)
    userDefaults.synchronize()
    print("⚙️ UserDefaults REMOVED: \(key)")
  }
  
  func exists(for key: String) -> Bool {
    return userDefaults.object(forKey: key) != nil
  }
  
  // MARK: - Session Properties
  var currentUserId: String? {
    get { userDefaults.string(forKey: Keys.currentUserId) }
    set {
      if let newValue = newValue {
        set(newValue, for: Keys.currentUserId)
      } else {
        remove(for: Keys.currentUserId)
      }
    }
  }
  
  var isFirstLaunch: Bool {
    get { get(Bool.self, for: Keys.isFirstLaunch, defaultValue: true) }
    set { set(newValue, for: Keys.isFirstLaunch) }
  }
  
  var lastSyncDate: Date? {
    get { userDefaults.object(forKey: Keys.lastSyncDate) as? Date }
    set {
      if let newValue = newValue {
        set(newValue, for: Keys.lastSyncDate)
      } else {
        remove(for: Keys.lastSyncDate)
      }
    }
  }
  
  var isUserLoggedIn: Bool {
    get { get(Bool.self, for: Keys.isUserLoggedIn, defaultValue: false) }
    set { set(newValue, for: Keys.isUserLoggedIn) }
  }
  
  // MARK: - User Management Methods (All in UserDefaults)
  func saveCurrentUser(_ user: User) {
    do {
      // Configure JSONEncoder dengan date strategy
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      
      let userData = try encoder.encode(user)
      set(userData, for: Keys.currentUserData)
      setUserSession(userId: user.id)
      
      print("✅ User saved: \(user.fullName)")
      
    } catch {
      print("❌ Failed to save user: \(error.localizedDescription)")
    }
  }
  
  func getCurrentUser() -> User? {
    guard isUserLoggedIn else {
      print("🔍 No active user session")
      return nil
    }
    
    let userData: Data = get(Data.self, for: Keys.currentUserData, defaultValue: Data())
    guard !userData.isEmpty else {
      print("🔍 No user data found")
      return nil
    }
    
    do {
      // Configure JSONDecoder dengan date strategy
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      let user = try decoder.decode(User.self, from: userData)
      print("✅ Retrieved user: \(user.fullName)")
      return user
      
    } catch {
      print("❌ Failed to decode user: \(error.localizedDescription)")
      print("❌ Error details: \(error)")
      clearUserSession() // Clear corrupted session
      return nil
    }
  }
  
  func clearUserSession() {
    currentUserId = nil
    isUserLoggedIn = false
    lastSyncDate = nil
    remove(for: Keys.currentUserData)
    
    print("⚙️ User session cleared")
  }
  
  func setUserSession(userId: String) {
    currentUserId = userId
    isUserLoggedIn = true
    lastSyncDate = Date()
    print("⚙️ User session set for: \(userId)")
  }
  
  func hasValidSession() -> Bool {
    return isUserLoggedIn && getCurrentUser() != nil
  }
}
