//
//  PresentationAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import Foundation
import Swinject

final class PresentationAssembly: Assembly {
  func assemble(container: Container) {
    container.register(SplashViewModel.self) { resolver in
      return SplashViewModel()
    }
    
    container.register(SplashViewController.self) { resolver in
      let viewController = SplashViewController()
      
      guard let viewModel = resolver.resolve(SplashViewModel.self) else {
        fatalError("❌ DI: Failed to resolve SplashViewModel")
      }
      
      viewController.viewModel = viewModel
      return viewController
    }
  }
}
