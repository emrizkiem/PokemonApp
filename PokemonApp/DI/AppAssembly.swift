//
//  AppAssembly.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import Foundation
import Swinject

final class AppAssembly: Assembly {
  
  func assemble(container: Container) {
    container.register(SplashCoordinatorProtocol.self) { resolver in
      SplashCoordinator(container: resolver)
    }
  }
}
