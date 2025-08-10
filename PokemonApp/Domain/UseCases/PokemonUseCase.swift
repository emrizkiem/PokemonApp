//
//  PokemonUseCase.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation
import RxSwift

protocol PokemonUseCaseProtocol {
  func fetchPokemonList(limit: Int, offset: Int) -> Observable<PokemonPage>
  func fetchPokemonDetail(id: Int) -> Observable<Pokemon>
  func fetchPokemonByName(_ name: String) -> Observable<Pokemon>
  func searchPokemon(_ query: String, limit: Int, offset: Int) -> Observable<PokemonPage>
}

final class PokemonUseCase: PokemonUseCaseProtocol {
  
  private let repository: PokemonRepositoryProtocol
  
  init(repository: PokemonRepositoryProtocol) {
    self.repository = repository
  }
  
  func fetchPokemonList(limit: Int = 20, offset: Int = 0) -> Observable<PokemonPage> {
    let validatedLimit = max(1, min(limit, 100))
    let validatedOffset = max(0, offset)
    
    return repository.fetchPokemonList(limit: validatedLimit, offset: validatedOffset)
  }
  
  func fetchPokemonDetail(id: Int) -> Observable<Pokemon> {
    guard id > 0 else {
      return Observable.error(PokemonError.invalidPokemonId)
    }
    
    return repository.fetchPokemonDetail(id: id)
  }
  
  func fetchPokemonByName(_ name: String) -> Observable<Pokemon> {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmedName.isEmpty else {
      return Observable.error(PokemonError.invalidPokemonName)
    }
    
    return repository.fetchPokemonByName(trimmedName)
  }
  
  func searchPokemon(_ query: String, limit: Int = 20, offset: Int = 0) -> Observable<PokemonPage> {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmedQuery.isEmpty else {
      let emptyPage = PokemonPage(
        pokemons: [],
        totalCount: 0,
        hasNextPage: false,
        hasPreviousPage: false,
        currentOffset: offset,
        currentLimit: limit
      )
      return Observable.just(emptyPage)
    }
    
    guard trimmedQuery.count >= 2 else {
      return Observable.error(PokemonError.queryTooShort)
    }
    
    return repository.searchPokemon(trimmedQuery, limit: limit, offset: offset)
  }
}
