//
//  UserRepository.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift
import RealmSwift

final class UserRepository: UserRepositoryProtocol {
  
  private let databaseService: DatabaseServiceProtocol
  private let userDefaultsManager: UserDefaultsManagerProtocol
  private let disposeBag = DisposeBag()
  
  init(databaseService: DatabaseServiceProtocol, userDefaultsManager: UserDefaultsManagerProtocol) {
    self.databaseService = databaseService
    self.userDefaultsManager = userDefaultsManager
  }
  
  func loginUser(email: String, password: String) -> Observable<User?> {
    let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return databaseService.loginUser(email: cleanEmail, password: password)
      .do(onNext: { [weak self] user in
        if let user = user {
          self?.userDefaultsManager.setUserSession(userId: user.id)
          print("✅ Session saved for user: \(user.fullName)")
        }
      })
  }
  
  func registerUser(email: String, fullName: String, password: String) -> Observable<User> {
    let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    let cleanFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Basic validation
    guard ValidationUtils.isValidEmail(cleanEmail) else {
      return Observable.error(AuthError.invalidEmail)
    }
    
    guard password.count >= 6 else {
      return Observable.error(AuthError.weakPassword)
    }
    
    guard !cleanFullName.isEmpty else {
      return Observable.error(AuthError.registrationFailed)
    }
    
    return databaseService.registerUser(
      email: cleanEmail,
      fullName: cleanFullName,
      password: password
    )
    .do(onNext: { [weak self] user in
      self?.userDefaultsManager.setUserSession(userId: user.id)
      print("✅ Session saved for new user: \(user.fullName)")
    })
  }
  
  func getCurrentUser() -> Observable<User?> {
    guard let userId = userDefaultsManager.currentUserId else {
      return Observable.just(nil)
    }
    
    return databaseService.getUserById(userId: userId)
  }
  
  func isUserLoggedIn() -> Bool {
    return userDefaultsManager.currentUserId != nil
  }
  
  func logoutUser() -> Observable<Void> {
    userDefaultsManager.clearUserSession()
    return Observable.just(())
  }
}
