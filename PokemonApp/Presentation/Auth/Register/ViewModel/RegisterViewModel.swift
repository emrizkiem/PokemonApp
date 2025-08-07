//
//  RegisterViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol RegisterViewModelProtocol: BaseViewModelProtocol {
  var fullName: BehaviorRelay<String> { get }
  var email: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var registerSuccess: PublishRelay<User> { get }
  var registerError: PublishRelay<String> { get }
  
  func register()
}

final class RegisterViewModel: BaseViewModel, RegisterViewModelProtocol {
  
  let fullName = BehaviorRelay<String>(value: "")
  let email = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let registerSuccess = PublishRelay<User>()
  let registerError = PublishRelay<String>()
  
  private let registerUseCase: RegisterUseCaseProtocol
  
  init(registerUseCase: RegisterUseCaseProtocol) {
    self.registerUseCase = registerUseCase
    super.init()
  }
  
  func register() {
    let fullNameValue = fullName.value.trimmingCharacters(in: .whitespacesAndNewlines)
    let emailValue = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
    let passwordValue = password.value
    
    guard !fullNameValue.isEmpty else {
      registerError.accept("Please enter your full name")
      return
    }
    
    guard fullNameValue.count >= 2 else {
      registerError.accept("Full name must be at least 2 characters")
      return
    }
    
    guard !emailValue.isEmpty else {
      registerError.accept("Please enter your email address")
      return
    }
    
    guard ValidationUtils.isValidEmail(emailValue) else {
      registerError.accept("Please enter a valid email address")
      return
    }
    
    guard !passwordValue.isEmpty else {
      registerError.accept("Please enter your password")
      return
    }
    
    guard ValidationUtils.isValidPassword(passwordValue) else {
      registerError.accept("Password must be at least 6 characters")
      return
    }
    
    setLoading(true)
    
    registerUseCase.execute(
      email: emailValue,
      fullName: fullNameValue,
      password: passwordValue
    )
    .observe(on: MainScheduler.instance)
    .subscribe(
      onNext: { [weak self] result in
        self?.setLoading(false)
        
        switch result {
        case .success(let user):
          self?.registerSuccess.accept(user)
        case .failure(let authError):
          self?.registerError.accept(authError.errorDescription ?? "Registration failed")
        }
      },
      onError: { [weak self] error in
        self?.setLoading(false)
        self?.registerError.accept("An unexpected error occurred. Please try again.")
      }
    )
    .disposed(by: disposeBag)
  }
}
