//
//  ProfileViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileViewModelProtocol: BaseViewModelProtocol {
  var user: BehaviorRelay<User?> { get }
  var logoutSuccess: PublishSubject<Void> { get }
  
  func updateUser(_ user: User)
  func logout()
}

final class ProfileViewModel: BaseViewModel, ProfileViewModelProtocol {
  
  // MARK: - Outputs
  let user = BehaviorRelay<User?>(value: nil)
  let logoutSuccess = PublishSubject<Void>()
  
  // MARK: - Private Properties
//  private let authService: AuthServiceProtocol?
  
//  init(authService: AuthServiceProtocol? = nil) {
//    self.authService = authService
//    super.init()
//  }
  
  override func initialize() {
    super.initialize()
  }
  
  func updateUser(_ user: User) {
    self.user.accept(user)
  }
  
  func logout() {
    isLoading.accept(true)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.isLoading.accept(false)
      self?.logoutSuccess.onNext(())
      print("User logged out")
    }
  }
}
