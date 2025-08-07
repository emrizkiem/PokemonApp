//
//  AppCoordinator.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit
import Swinject

protocol AppCoordinatorProtocol {
  func start()
}

final class AppCoordinator: AppCoordinatorProtocol {
  
  private let window: UIWindow
  private let container = DIContainer.shared.container
  
  private var splashCoordinator: SplashCoordinatorProtocol?
  private var authCoordinator: AuthCoordinatorProtocol?
  
  private lazy var mainNavigationController: UINavigationController = {
    let navController = UINavigationController()
    navController.setNavigationBarHidden(true, animated: false)
    return navController
  }()
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func start() {
    window.rootViewController = mainNavigationController
    window.makeKeyAndVisible()
    
    showSplashScreen()
  }
  
  private func showSplashScreen() {
    splashCoordinator = container.resolve(SplashCoordinatorProtocol.self)
    splashCoordinator?.delegate = self
    
    splashCoordinator?.start(navigationController: mainNavigationController)
  }
  
  private func showAuthFlow() {
    splashCoordinator?.delegate = nil
    splashCoordinator = nil
    
    authCoordinator = container.resolve(AuthCoordinatorProtocol.self)
    authCoordinator?.delegate = self
    authCoordinator?.start(navigationController: mainNavigationController)
  }
  
  private func showMainApp(user: User) {
    authCoordinator?.delegate = nil
    authCoordinator = nil
    
    // TODO: Implement MainAppCoordinator using same navigationController
    showTemporaryAlert(
      title: "Welcome! 🎉",
      message: "Hello \(user.fullName)!\n\nMain App Flow will be implemented next!"
    )
  }
  
  private func handleAuthCancellation() {
    authCoordinator?.delegate = nil
    authCoordinator = nil
    
    showSplashScreen()
  }
  
  private func showTemporaryAlert(title: String, message: String) {
    DispatchQueue.main.async { [weak self] in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
        self?.showAuthFlow()
      })
      
      alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
        self?.showAuthFlow()
      })
      
      self?.window.rootViewController?.present(alert, animated: true)
    }
  }
}

extension AppCoordinator: SplashCoordinatorDelegate {
  func splashDidFinish() {
    checkUserSession()
  }
  
  private func checkUserSession() {
    // TODO: Use GetCurrentUserUseCase to check if user is logged in
    /*
    getCurrentUserUseCase.execute()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] result in
        switch result {
        case .loggedIn(let user):
          print("✅ User already logged in: \(user.fullName)")
          self?.showMainApp(user: user)
          
        case .notLoggedIn:
          print("🎯 No active session, showing auth flow")
          self?.showAuthFlow()
          
        case .error(let error):
          print("❌ Session check error: \(error), showing auth flow")
          self?.showAuthFlow()
        }
      })
      .disposed(by: disposeBag)
    */
    
    // For now, always show auth flow
    showAuthFlow()
  }
}

extension AppCoordinator: AuthCoordinatorDelegate {
  func authDidComplete(user: User) {
    showMainApp(user: user)
  }
  
  func authDidCancel() {
    handleAuthCancellation()
  }
}
