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
  private let disposeBag = DisposeBag() 
  
  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }
  
  func execute(email: String, fullName: String, password: String) -> Observable<RegisterResult> {
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
        observer.onNext(.failure(.invalidEmail))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !cleanFullName.isEmpty else {
        observer.onNext(.failure(.invalidFullName))
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard !password.isEmpty else {
        observer.onNext(.failure(.weakPassword))
        observer.onCompleted()
        return Disposables.create()
      }
      
      print("RegisterUseCase: Calling repository.registerUser")
    
      let subscription = self.userRepository.registerUser(
        email: cleanEmail,
        fullName: cleanFullName,
        password: password
      )
        .subscribe(
          onNext: { user in
            print("RegisterUseCase: Registration successful for \(user.fullName)")
            observer.onNext(.success(user))
            observer.onCompleted()
          },
          onError: { error in
            print("RegisterUseCase: Registration error - \(error)")
            
            if let authError = error as? AuthError {
              observer.onNext(.failure(authError))
            } else {
              observer.onNext(.failure(.registrationFailed))
            }
            observer.onCompleted()
          },
          onCompleted: {
            print("RegisterUseCase: Repository observable completed")
          }
        )
      
      return Disposables.create {
        subscription.dispose()
      }
    }
  }
}
