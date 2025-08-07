//
//  AuthCoordinator.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import UIKit
import Swinject

protocol AuthCoordinatorProtocol {
  var delegate: AuthCoordinatorDelegate? { get set }
  func start(navigationController: UINavigationController)
  func showLogin()
  func showRegister()
}

protocol AuthCoordinatorDelegate: AnyObject {
  func authDidComplete(user: User)
  func authDidCancel()
}

final class AuthCoordinator: AuthCoordinatorProtocol {
  
  weak var delegate: AuthCoordinatorDelegate?
  private let container: Resolver
  private var navigationController: UINavigationController?

  init(container: Resolver) {
    self.container = container
  }
  
  func start(navigationController: UINavigationController) {
    self.navigationController = navigationController
    showLogin()
  }
  
  func showLogin() {
    guard let loginViewController = container.resolve(LoginViewController.self) else {
      fatalError("❌ Failed to resolve LoginViewController from DI container")
    }
    
    guard loginViewController.viewModel != nil else {
      fatalError("❌ LoginViewController created without ViewModel injection")
    }
    
    loginViewController.delegate = self
    navigationController?.setViewControllers([loginViewController], animated: false)
    
    loginViewController.view.alpha = 0
    UIView.animate(withDuration: 0.25) {
      loginViewController.view.alpha = 1
    }
  }
  
  func showRegister() {
    guard let registerViewController = container.resolve(RegisterViewController.self) else {
      fatalError("❌ Failed to resolve RegisterViewController from DI container")
    }
    
    guard registerViewController.viewModel != nil else {
      fatalError("❌ RegisterViewController created without ViewModel injection")
    }
    
    registerViewController.delegate = self
    navigationController?.pushViewController(registerViewController, animated: false)

    registerViewController.view.alpha = 0
    UIView.animate(withDuration: 0.25) {
      registerViewController.view.alpha = 1
    }
  }
  
  private func goBackToLogin() {
    guard let currentViewController = navigationController?.topViewController else { return }
    
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseIn
    ) {
      currentViewController.view.alpha = 0
    } completion: { [weak self] _ in
      self?.navigationController?.popToRootViewController(animated: false)
      currentViewController.view.alpha = 1
    }
  }
  
  private func handleAuthSuccess(user: User) {
    delegate?.authDidComplete(user: user)
  }
}

extension AuthCoordinator: LoginViewControllerDelegate {
  func loginDidSucceed(user: User) {
    let userDefaultsManager = container.resolve(UserDefaultsManagerProtocol.self)!
    userDefaultsManager.saveCurrentUser(user)
    
    handleAuthSuccess(user: user)
  }
  
  func loginRequestRegister() {
    showRegister()
  }
}

extension AuthCoordinator: RegisterViewControllerDelegate {
  func registerDidSucceed(user: User) {
    let userDefaultsManager = container.resolve(UserDefaultsManagerProtocol.self)!
    userDefaultsManager.saveCurrentUser(user)
    
    handleAuthSuccess(user: user)
  }
  
  func registerRequestLogin() {
    goBackToLogin()
  }
}
