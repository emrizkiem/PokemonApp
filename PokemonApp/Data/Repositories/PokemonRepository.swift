//
//  PokemonRepository.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation
import RxSwift

final class PokemonRepository: PokemonRepositoryProtocol {
  
  private let networkService: NetworkServiceProtocol
  private var pokemonCache: [Int: Pokemon] = [:] // Cache by ID
  private var pokemonListCache: [Pokemon] = [] // Cache loaded pages
  private var totalPokemonCount: Int = 0
  
  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
  
  func fetchPokemonList(limit: Int, offset: Int) -> Observable<PokemonPage> {
    return networkService
      .request(PokemonEndpoint.pokemonList(limit: limit, offset: offset), responseType: PokemonListResponse.self)
      .map { [weak self] response in
        
        let simplePokemons = response.results.compactMap { $0.toSimplePokemon() }
        
        self?.cachePokemonList(simplePokemons)
        self?.totalPokemonCount = response.count
        
        return PokemonPage(
          pokemons: simplePokemons,
          totalCount: response.count,
          hasNextPage: response.next != nil,
          hasPreviousPage: response.previous != nil,
          currentOffset: offset,
          currentLimit: limit
        )
      }
      .catch { error in
        return Observable.error(error)
      }
  }
  
  func searchPokemon(_ query: String, limit: Int, offset: Int) -> Observable<PokemonPage> {
    let cacheResults = searchInCache(query: query, limit: limit, offset: offset)
    if !cacheResults.pokemons.isEmpty || pokemonListCache.count >= 200 {
      return Observable.just(cacheResults)
    }
    
    if let pokemonId = Int(query) {
      return searchByPokemonId(pokemonId, limit: limit, offset: offset)
    }
    
    return searchByNameFromAPI(query: query, limit: limit, offset: offset)
  }
  
  private func searchInCache(query: String, limit: Int, offset: Int) -> PokemonPage {
    let filtered = pokemonListCache.filter { pokemon in
      pokemon.name.lowercased().contains(query.lowercased()) ||
      (Int(query) != nil && pokemon.id == Int(query)!)
    }
    
    let startIndex = offset
    let endIndex = min(startIndex + limit, filtered.count)
    let paginatedResults = Array(filtered[startIndex..<endIndex])
    
    return PokemonPage(
      pokemons: paginatedResults,
      totalCount: filtered.count,
      hasNextPage: endIndex < filtered.count,
      hasPreviousPage: offset > 0,
      currentOffset: offset,
      currentLimit: limit
    )
  }
  
  private func searchByPokemonId(_ pokemonId: Int, limit: Int, offset: Int) -> Observable<PokemonPage> {
    
    if let cachedPokemon = pokemonCache[pokemonId] {
      let page = PokemonPage(
        pokemons: [cachedPokemon],
        totalCount: 1,
        hasNextPage: false,
        hasPreviousPage: false,
        currentOffset: 0,
        currentLimit: limit
      )
      return Observable.just(page)
    }
    
    return fetchPokemonDetail(id: pokemonId)
      .map { pokemon in
        PokemonPage(
          pokemons: [pokemon],
          totalCount: 1,
          hasNextPage: false,
          hasPreviousPage: false,
          currentOffset: 0,
          currentLimit: limit
        )
      }
      .catch { error in
        return Observable.just(PokemonPage(
          pokemons: [],
          totalCount: 0,
          hasNextPage: false,
          hasPreviousPage: false,
          currentOffset: offset,
          currentLimit: limit
        ))
      }
  }
  
  private func searchByNameFromAPI(query: String, limit: Int, offset: Int) -> Observable<PokemonPage> {
    return networkService
      .request(PokemonEndpoint.pokemonList(limit: 200, offset: 0), responseType: PokemonListResponse.self)
      .timeout(.seconds(15), scheduler: MainScheduler.instance)
      .map { [weak self] response in
        let allPokemon = response.results.compactMap { $0.toSimplePokemon() }
        
        self?.cachePokemonList(allPokemon)
        
        let filtered = allPokemon.filter { pokemon in
          pokemon.name.lowercased().contains(query.lowercased())
        }
        
        let startIndex = offset
        let endIndex = min(startIndex + limit, filtered.count)
        let paginatedResults = Array(filtered[startIndex..<endIndex])
        
        return PokemonPage(
          pokemons: paginatedResults,
          totalCount: filtered.count,
          hasNextPage: endIndex < filtered.count,
          hasPreviousPage: offset > 0,
          currentOffset: offset,
          currentLimit: limit
        )
      }
      .catch { error in
        return Observable.just(PokemonPage(
          pokemons: [],
          totalCount: 0,
          hasNextPage: false,
          hasPreviousPage: false,
          currentOffset: offset,
          currentLimit: limit
        ))
      }
  }
  
  private func cachePokemonList(_ pokemonList: [Pokemon]) {
    for pokemon in pokemonList {
      if !pokemonListCache.contains(where: { $0.id == pokemon.id }) {
        pokemonListCache.append(pokemon)
      }
      
      pokemonCache[pokemon.id] = pokemon
    }
    pokemonListCache.sort { $0.id < $1.id }
  }
  
  func fetchPokemonDetail(id: Int) -> Observable<Pokemon> {
    if let cachedPokemon = pokemonCache[id] {
      return Observable.just(cachedPokemon)
    }
    
    return networkService
      .request(PokemonEndpoint.pokemonDetail(id: id), responseType: PokemonDetailResponse.self)
      .map { [weak self] response in
        let pokemon = response.toDomain()
        self?.pokemonCache[id] = pokemon
        return pokemon
      }
  }
  
  func fetchPokemonByName(_ name: String) -> Observable<Pokemon> {
    return networkService
      .request(PokemonEndpoint.pokemonByName(name: name), responseType: PokemonDetailResponse.self)
      .map { [weak self] response in
        let pokemon = response.toDomain()
        self?.pokemonCache[pokemon.id] = pokemon
        return pokemon
      }
  }
}
