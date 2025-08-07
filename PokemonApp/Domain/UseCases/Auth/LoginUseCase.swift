//
//  LoginUseCase.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift

protocol LoginUseCaseProtocol {
  func execute(email: String, password: String) -> Observable<LoginResult>
}

enum LoginResult {
  case success(User)
  case failure(AuthError)
}

final class LoginUseCase: LoginUseCaseProtocol {
  
  private let userRepository: UserRepositoryProtocol
  private let disposeBag = DisposeBag()
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }
  
  func execute(email: String, password: String) -> Observable<LoginResult> {
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onNext(.failure(.loginFailed))
        observer.onCompleted()
        return Disposables.create()
      }
      
      let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !cleanEmail.isEmpty else {
        observer.onNext(.failure(.invalidEmail))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !password.isEmpty else {
        observer.onNext(.failure(.invalidCredentials))
        observer.onCompleted()
        return Disposables.create()
      }
      
      print("LoginUseCase: Calling repository.loginUser")
      
      let subscription = self.userRepository.loginUser(email: cleanEmail, password: password)
        .subscribe(
          onNext: { user in
            print("🎯 LoginUseCase: Repository returned result")
            
            if let user = user {
              print("LoginUseCase: Login successful for \(user.fullName)")
              observer.onNext(.success(user))
            } else {
              print("LoginUseCase: Invalid credentials (user not found or wrong password)")
              observer.onNext(.failure(.invalidCredentials))
            }
            observer.onCompleted()
          },
          onError: { error in
            print("LoginUseCase: Repository returned error - \(error)")
            
            if let authError = error as? AuthError {
              observer.onNext(.failure(authError))
            } else {
              observer.onNext(.failure(.loginFailed))
            }
            observer.onCompleted()
          },
          onCompleted: {
            print("LoginUseCase: Repository observable completed")
          }
        )
    
      return Disposables.create {
        subscription.dispose()
      }
    }
  }
}
