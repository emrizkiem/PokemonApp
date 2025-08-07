//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - HomeViewModel
protocol HomeViewModelProtocol: BaseViewModelProtocol {
  // Future: Add pokemon search, fetch methods
//  var pokemonList: BehaviorRelay<[Pokemon]> { get }
//  var searchQuery: BehaviorRelay<String> { get }
  
  func searchPokemon(query: String)
  func loadPokemon()
}

final class HomeViewModel: BaseViewModel, HomeViewModelProtocol {
  
  // MARK: - Outputs
//  let pokemonList = BehaviorRelay<[Pokemon]>(value: [])
//  let searchQuery = BehaviorRelay<String>(value: "")
  
  // MARK: - Private Properties
//  private let pokemonService: PokemonServiceProtocol?
  
//  init(pokemonService: PokemonServiceProtocol? = nil) {
//    self.pokemonService = pokemonService
//    super.init()
//  }
  
  override func initialize() {
    super.initialize()
    // For now, just dummy implementation
    print("HomeViewModel initialized")
  }
  
  override func activate() {
    super.activate()
    loadPokemon()
  }
  
  func searchPokemon(query: String) {
//    searchQuery.accept(query)
    // TODO: Implement search logic when API is integrated
    print("Searching for: \(query)")
  }
  
  func loadPokemon() {
    // TODO: Replace with actual API call
    print("Loading Pokemon (dummy for now)")
    
    // Dummy implementation - will be replaced with actual API call
//    let dummyPokemon: [Pokemon] = []
//    pokemonList.accept(dummyPokemon)
  }
}
