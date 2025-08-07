//
//  LogoutUseCase.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift

protocol LogoutUseCaseProtocol {
  func execute() -> Observable<LogoutResult>
}

enum LogoutResult {
  case success
  case failure(AuthError)
}

final class LogoutUseCase: LogoutUseCaseProtocol {
  
  private let userRepository: UserRepositoryProtocol
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }
  
  func execute() -> Observable<LogoutResult> {
    return userRepository.logoutUser()
      .map { _ in
        return LogoutResult.success
      }
      .catch { error in
        return Observable.just(.failure(.loginFailed))
      }
  }
}
