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
  private let disposeBag = DisposeBag() // ✅ FIX: Use instance property
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
    print("🎯 LoginUseCase initialized")
  }
  
  deinit {
    print("🎯 LoginUseCase deinitialized")
  }
  
  func execute(email: String, password: String) -> Observable<LoginResult> {
    print("🎯 LoginUseCase: Executing login for \(email)")
    
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onNext(.failure(.loginFailed))
        observer.onCompleted()
        return Disposables.create()
      }
      
      // Input validation
      let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !cleanEmail.isEmpty else {
        print("❌ LoginUseCase: Empty email provided")
        observer.onNext(.failure(.invalidEmail))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !password.isEmpty else {
        print("❌ LoginUseCase: Empty password provided")
        observer.onNext(.failure(.invalidCredentials))
        observer.onCompleted()
        return Disposables.create()
      }
      
      print("🎯 LoginUseCase: Calling repository.loginUser")
      
      // ✅ FIX: Use instance disposeBag and remove timeout (repository handles it)
      let subscription = self.userRepository.loginUser(email: cleanEmail, password: password)
        .subscribe(
          onNext: { user in
            print("🎯 LoginUseCase: Repository returned result")
            
            if let user = user {
              print("✅ LoginUseCase: Login successful for \(user.fullName)")
              observer.onNext(.success(user))
            } else {
              print("❌ LoginUseCase: Invalid credentials (user not found or wrong password)")
              observer.onNext(.failure(.invalidCredentials))
            }
            observer.onCompleted()
          },
          onError: { error in
            print("❌ LoginUseCase: Repository returned error - \(error)")
            
            // Map different error types
            if let authError = error as? AuthError {
              observer.onNext(.failure(authError))
            } else {
              observer.onNext(.failure(.loginFailed))
            }
            observer.onCompleted()
          },
          onCompleted: {
            print("🎯 LoginUseCase: Repository observable completed")
          }
        )
      
      // ✅ FIX: Return proper disposable
      return Disposables.create {
        subscription.dispose()
      }
    }
  }
}
