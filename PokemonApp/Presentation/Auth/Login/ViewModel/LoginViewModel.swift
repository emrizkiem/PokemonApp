//
//  LoginViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginViewModelProtocol: BaseViewModelProtocol {
  var email: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var loginSuccess: PublishRelay<User> { get }
  var loginError: PublishRelay<String> { get }
  
  func login()
}

final class LoginViewModel: BaseViewModel, LoginViewModelProtocol {
  
  let email = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginSuccess = PublishRelay<User>()
  let loginError = PublishRelay<String>()
  
  private let loginUseCase: LoginUseCaseProtocol
  
  init(loginUseCase: LoginUseCaseProtocol) {
    self.loginUseCase = loginUseCase
    super.init()
  }
  
  func login() {
    let emailValue = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
    let passwordValue = password.value
    
    guard !emailValue.isEmpty else {
      loginError.accept("Please enter your email address")
      return
    }
    
    guard ValidationUtils.isValidEmail(emailValue) else {
      loginError.accept("Please enter a valid email address")
      return
    }
    
    guard !passwordValue.isEmpty else {
      loginError.accept("Please enter your password")
      return
    }
    
    guard ValidationUtils.isValidPassword(passwordValue) else {
      loginError.accept("Password must be at least 6 characters")
      return
    }
    
    setLoading(true)
    
    loginUseCase.execute(email: emailValue, password: passwordValue)
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] result in
          self?.setLoading(false)
          
          switch result {
          case .success(let user):
            self?.loginSuccess.accept(user)
          case .failure(let authError):
            self?.loginError.accept(authError.errorDescription ?? "Login failed")
          }
        },
        onError: { [weak self] error in
          self?.setLoading(false)
          self?.loginError.accept("An unexpected error occurred. Please try again.")
        }
      )
      .disposed(by: disposeBag)
  }
}
