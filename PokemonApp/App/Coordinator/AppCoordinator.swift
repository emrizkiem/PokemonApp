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
  private var mainAppCoordinator: MainTabBarCoordinatorProtocol?
  
  private lazy var userDefaultsManager: UserDefaultsManagerProtocol = {
    return container.resolve(UserDefaultsManagerProtocol.self)!
  }()
  
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
    cleanupSplashCoordinator()
    
    authCoordinator = container.resolve(AuthCoordinatorProtocol.self)
    authCoordinator?.delegate = self
    authCoordinator?.start(navigationController: mainNavigationController)
  }
  
  private func showMainApp(user: User) {
    cleanupAuthCoordinator()
    
    mainAppCoordinator = container.resolve(MainTabBarCoordinatorProtocol.self, argument: user)
    mainAppCoordinator?.delegate = self
    mainAppCoordinator?.start(navigationController: mainNavigationController)
  }
  
  private func handleAuthCancellation() {
    cleanupAuthCoordinator()
    showSplashScreen()
  }
  
  private func handleMainAppLogout() {
    cleanupMainAppCoordinator()
    showAuthFlow()
  }
  
  private func cleanupSplashCoordinator() {
    splashCoordinator?.delegate = nil
    splashCoordinator = nil
  }
  
  private func cleanupAuthCoordinator() {
    authCoordinator?.delegate = nil
    authCoordinator = nil
  }
  
  private func cleanupMainAppCoordinator() {
    mainAppCoordinator?.delegate = nil
    mainAppCoordinator = nil
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
    if userDefaultsManager.hasValidSession() {
      guard let user = userDefaultsManager.getCurrentUser() else {
        showAuthFlow()
        return
      }
      
      showMainApp(user: user)
    } else {
      showAuthFlow()
    }
  }
}

extension AppCoordinator: AuthCoordinatorDelegate {
  func authDidComplete(user: User) {
    userDefaultsManager.saveCurrentUser(user)
    showMainApp(user: user)
  }
  
  func authDidCancel() {
    handleAuthCancellation()
  }
}

extension AppCoordinator: MainTabBarCoordinatorDelegate {
  func mainAppDidLogout() {
    handleMainAppLogout()
  }
}
