//
//  SplashCoordinator.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit
import Swinject

protocol SplashCoordinatorProtocol {
  var delegate: SplashCoordinatorDelegate? { get set }
  func start(window: UIWindow)
}

protocol SplashCoordinatorDelegate: AnyObject {
  func splashDidFinish()
}

final class SplashCoordinator: SplashCoordinatorProtocol {
  
  weak var delegate: SplashCoordinatorDelegate?
  private let container: Resolver
  
  init(container: Resolver) {
    self.container = container
  }
  
  func start(window: UIWindow) {
    guard let splashViewController = container.resolve(SplashViewController.self) else {
      fatalError("❌ Failed to resolve SplashViewController from DI container")
    }
    
    if splashViewController.viewModel == nil {
      fatalError("❌ SplashViewController created without ViewModel injection")
    }
    
    splashViewController.delegate = self
    
    window.rootViewController = splashViewController
    window.makeKeyAndVisible()
  }
}

extension SplashCoordinator: SplashViewControllerDelegate {
  func splashDidComplete() {
    delegate?.splashDidFinish()
  }
}
