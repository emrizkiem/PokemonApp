//
//  DomainAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import Swinject

final class DomainAssembly: Assembly {
  
  func assemble(container: Container) {
    container.register(LoginUseCaseProtocol.self) { resolver in
      
      guard let userRepository = resolver.resolve(UserRepositoryProtocol.self) else {
        fatalError("❌ Failed to resolve UserRepository for LoginUseCase")
      }
      
      return LoginUseCase(userRepository: userRepository)
    }.inObjectScope(.container)
    
    container.register(RegisterUseCaseProtocol.self) { resolver in
      
      guard let userRepository = resolver.resolve(UserRepositoryProtocol.self) else {
        fatalError("❌ Failed to resolve UserRepository for RegisterUseCase")
      }
      
      return RegisterUseCase(userRepository: userRepository)
    }.inObjectScope(.container)
    
    container.register(LogoutUseCaseProtocol.self) { resolver in
      
      guard let userRepository = resolver.resolve(UserRepositoryProtocol.self) else {
        fatalError("❌ Failed to resolve UserRepository for LogoutUseCase")
      }
      
      return LogoutUseCase(userRepository: userRepository)
    }.inObjectScope(.container)
    
    container.register(GetCurrentUserUseCaseProtocol.self) { resolver in
      
      guard let userRepository = resolver.resolve(UserRepositoryProtocol.self) else {
        fatalError("❌ Failed to resolve UserRepository for GetCurrentUserUseCase")
      }
      
      return GetCurrentUserUseCase(userRepository: userRepository)
    }.inObjectScope(.container)
  }
}
