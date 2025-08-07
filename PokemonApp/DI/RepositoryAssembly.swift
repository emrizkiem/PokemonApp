//
//  RepositoryAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import Swinject

final class RepositoryAssembly: Assembly {
  
  func assemble(container: Container) {
    container.register(UserRepositoryProtocol.self) { resolver in
      
      guard let databaseService = resolver.resolve(DatabaseServiceProtocol.self),
            let userDefaultsManager = resolver.resolve(UserDefaultsManagerProtocol.self) else {
        fatalError("❌ Failed to resolve dependencies for UserRepository")
      }
      
      let repository = UserRepository(
        databaseService: databaseService,
        userDefaultsManager: userDefaultsManager
      )
      return repository
      
    }.inObjectScope(.container)
  }
}
