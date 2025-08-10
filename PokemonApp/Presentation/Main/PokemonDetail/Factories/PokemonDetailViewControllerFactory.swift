//
//  PokemonDetailViewControllerFactory.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 11/08/25.
//

import Foundation
import Swinject

protocol PokemonDetailViewControllerFactory {
  func createPokemonDetailViewController(pokemon: Pokemon) -> PokemonDetailViewController
}

final class PokemonDetailViewControllerFactoryImpl: PokemonDetailViewControllerFactory {
  
  private let container: Resolver
  
  init(container: Resolver) {
    self.container = container
  }
  
  func createPokemonDetailViewController(pokemon: Pokemon) -> PokemonDetailViewController {
    guard let pokemonUseCase = container.resolve(PokemonUseCaseProtocol.self) else {
      fatalError("❌ Failed to resolve PokemonUseCaseProtocol for Pokemon detail")
    }
    
    let viewModel = PokemonDetailViewModel(
      pokemon: pokemon,
      pokemonUseCase: pokemonUseCase
    )
    
    let viewController = PokemonDetailViewController()
    viewController.viewModel = viewModel
    return viewController
  }
}
