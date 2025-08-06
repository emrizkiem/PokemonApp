//
//  NetworkAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import Swinject

final class NetworkAssembly: Assembly {
  func assemble(container: Container) {
    container.register(NetworkServiceProtocol.self) { resolver in
      let networkService = NetworkService()
      return networkService
    }.inObjectScope(.container) // Singleton - one instance throughout app lifecycle
  }
}
