//
//  DatabaseAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import Swinject

final class DatabaseAssembly: Assembly {
  func assemble(container: Container) {
    container.register(DatabaseServiceProtocol.self) { resolver in
      do {
        return try DatabaseService()
      } catch {
        fatalError("Failed to initialize database")
      }
    }.inObjectScope(.container)
    
    container.register(UserDefaultsManagerProtocol.self) { resolver in
      return UserDefaultsManager()
    }.inObjectScope(.container)
  }
}
