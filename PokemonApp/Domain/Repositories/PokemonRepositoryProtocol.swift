//
//  PokemonRepositoryProtocol.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation
import RxSwift

protocol PokemonRepositoryProtocol {
  func fetchPokemonList(limit: Int, offset: Int) -> Observable<PokemonPage>
  func fetchPokemonDetail(id: Int) -> Observable<Pokemon>
  func fetchPokemonByName(_ name: String) -> Observable<Pokemon>
  func searchPokemon(_ query: String, limit: Int, offset: Int) -> Observable<PokemonPage>
}
