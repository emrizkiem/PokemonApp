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
    print("🎯 LogoutUseCase initialized")
  }
  
  func execute() -> Observable<LogoutResult> {
    print("🎯 LogoutUseCase: Executing logout")
    
    return userRepository.logoutUser()
      .map { _ in
        print("✅ LogoutUseCase: Logout successful")
        return LogoutResult.success
      }
      .catch { error in
        print("❌ LogoutUseCase: Logout error - \(error)")
        return Observable.just(.failure(.loginFailed))
      }
  }
}
