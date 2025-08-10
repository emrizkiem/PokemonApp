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
  }
  
  func execute() -> Observable<CurrentUserResult> {
    guard userRepository.isUserLoggedIn() else {
      return Observable.just(.notLoggedIn)
    }
    
    return userRepository.getCurrentUser()
      .map { user in
        if let user = user {
          return CurrentUserResult.loggedIn(user)
        } else {
          return CurrentUserResult.notLoggedIn
        }
      }
      .catch { error in
        return Observable.just(.error(.sessionExpired))
      }
  }
}
