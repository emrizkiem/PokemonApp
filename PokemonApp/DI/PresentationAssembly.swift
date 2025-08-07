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
    assembleSplashModule(container: container)
    assembleAuthModule(container: container)
  }
  
  private func assembleSplashModule(container: Container) {
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
  
  private func assembleAuthModule(container: Container) {
    container.register(LoginViewModel.self) { resolver in
      guard let loginUseCase = resolver.resolve(LoginUseCaseProtocol.self) else {
        fatalError("❌ DI: Failed to resolve LoginUseCaseProtocol")
      }
      
      return LoginViewModel(loginUseCase: loginUseCase)
    }
    
    container.register(LoginViewController.self) { resolver in
      let viewController = LoginViewController()
      
      guard let viewModel = resolver.resolve(LoginViewModel.self) else {
        fatalError("❌ DI: Failed to resolve LoginViewModel")
      }
      
      viewController.viewModel = viewModel
      return viewController
    }
    
    container.register(RegisterViewModel.self) { resolver in
      guard let registerUseCase = resolver.resolve(RegisterUseCaseProtocol.self) else {
        fatalError("❌ DI: Failed to resolve RegisterUseCaseProtocol")
      }
      
      return RegisterViewModel(registerUseCase: registerUseCase)
    }
    
    container.register(RegisterViewController.self) { resolver in
      let viewController = RegisterViewController()
      
      guard let viewModel = resolver.resolve(RegisterViewModel.self) else {
        fatalError("❌ DI: Failed to resolve RegisterViewModel")
      }
      
      viewController.viewModel = viewModel
      return viewController
    }
  }
}
