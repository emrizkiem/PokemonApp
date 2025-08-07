//
//  GetCurrentUseCase.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift

protocol GetCurrentUserUseCaseProtocol {
  func execute() -> Observable<CurrentUserResult>
}

enum CurrentUserResult {
  case loggedIn(User)
  case notLoggedIn
  case error(AuthError)
}

final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
  
  private let userRepository: UserRepositoryProtocol
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
    print("🎯 GetCurrentUserUseCase initialized")
  }
  
  func execute() -> Observable<CurrentUserResult> {
    print("🎯 GetCurrentUserUseCase: Getting current user")
    
    guard userRepository.isUserLoggedIn() else {
      print("🎯 GetCurrentUserUseCase: No active session")
      return Observable.just(.notLoggedIn)
    }
    
    return userRepository.getCurrentUser()
      .map { user in
        if let user = user {
          print("✅ GetCurrentUserUseCase: Current user found - \(user.fullName)")
          return CurrentUserResult.loggedIn(user)
        } else {
          print("🎯 GetCurrentUserUseCase: No current user in database")
          return CurrentUserResult.notLoggedIn
        }
      }
      .catch { error in
        print("❌ GetCurrentUserUseCase: Error getting current user - \(error)")
        return Observable.just(.error(.sessionExpired))
      }
  }
}
