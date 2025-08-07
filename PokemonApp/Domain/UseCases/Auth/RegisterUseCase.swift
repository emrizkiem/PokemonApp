//
//  RegisterUseCase.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift

protocol RegisterUseCaseProtocol {
  func execute(email: String, fullName: String, password: String) -> Observable<RegisterResult>
}

enum RegisterResult {
  case success(User)
  case failure(AuthError)
}

final class RegisterUseCase: RegisterUseCaseProtocol {
  
  private let userRepository: UserRepositoryProtocol
  private let disposeBag = DisposeBag() // ✅ FIX: Use instance property
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
    print("🎯 RegisterUseCase initialized")
  }
  
  deinit {
    print("🎯 RegisterUseCase deinitialized")
  }
  
  func execute(email: String, fullName: String, password: String) -> Observable<RegisterResult> {
    print("🎯 RegisterUseCase: Executing registration for \(email)")
    
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onNext(.failure(.registrationFailed))
        observer.onCompleted()
        return Disposables.create()
      }
      
      // Input validation and cleanup
      let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
      let cleanFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
      
      guard !cleanEmail.isEmpty else {
        print("❌ RegisterUseCase: Empty email provided")
        observer.onNext(.failure(.invalidEmail))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !cleanFullName.isEmpty else {
        print("❌ RegisterUseCase: Empty full name provided")
        observer.onNext(.failure(.invalidFullName))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !password.isEmpty else {
        print("❌ RegisterUseCase: Empty password provided")
        observer.onNext(.failure(.weakPassword))
        observer.onCompleted()
        return Disposables.create()
      }
      
      print("🎯 RegisterUseCase: Calling repository.registerUser")
      
      // ✅ FIX: Proper subscription management
      let subscription = self.userRepository.registerUser(
        email: cleanEmail,
        fullName: cleanFullName,
        password: password
      )
        .subscribe(
          onNext: { user in
            print("✅ RegisterUseCase: Registration successful for \(user.fullName)")
            observer.onNext(.success(user))
            observer.onCompleted()
          },
          onError: { error in
            print("❌ RegisterUseCase: Registration error - \(error)")
            
            if let authError = error as? AuthError {
              observer.onNext(.failure(authError))
            } else {
              observer.onNext(.failure(.registrationFailed))
            }
            observer.onCompleted()
          },
          onCompleted: {
            print("🎯 RegisterUseCase: Repository observable completed")
          }
        )
      
      // ✅ FIX: Return proper disposable
      return Disposables.create {
        subscription.dispose()
      }
    }
  }
}
