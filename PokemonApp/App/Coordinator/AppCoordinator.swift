//
//  AppCoordinator.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit

protocol AppCoordinatorProtocol {
  func start()
}

final class AppCoordinator: AppCoordinatorProtocol {
  
  private let window: UIWindow
  private let container = DIContainer.shared.container
  private var splashCoordinator: SplashCoordinatorProtocol?
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func start() {
    showSplashScreen()
  }
  
  private func showSplashScreen() {
    splashCoordinator = container.resolve(SplashCoordinatorProtocol.self)
    splashCoordinator?.delegate = self
    splashCoordinator?.start(window: window)
  }
  
  private func showAuthFlow() {
    showTemporaryAlert(title: "Next Phase", message: "Auth Flow (Login/Register) will be implemented next!")
  }
  
  private func showTemporaryAlert(title: String, message: String) {
    DispatchQueue.main.async { [weak self] in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Awesome! 🚀", style: .default) { _ in
        self?.showSplashScreen()
      })
      
      self?.window.rootViewController?.present(alert, animated: true)
    }
  }
}

extension AppCoordinator: SplashCoordinatorDelegate {
  func splashDidFinish() {
    showAuthFlow()
  }
}
