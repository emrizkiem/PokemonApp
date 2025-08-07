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
  func start(navigationController: UINavigationController)
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
  
  func start(navigationController: UINavigationController) {
    guard let splashViewController = container.resolve(SplashViewController.self) else {
      fatalError("❌ Failed to resolve SplashViewController from DI container")
    }
    
    if splashViewController.viewModel == nil {
      fatalError("❌ SplashViewController created without ViewModel injection")
    }
    
    splashViewController.delegate = self
    navigationController.setViewControllers([splashViewController], animated: false)
  }
}

extension SplashCoordinator: SplashViewControllerDelegate {
  func splashDidComplete() {
    self.delegate?.splashDidFinish()
  }
}
