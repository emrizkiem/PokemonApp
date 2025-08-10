//
//  PokemonError.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation

enum PokemonError: Error, LocalizedError {
  case invalidPokemonId
  case invalidPokemonName
  case queryTooShort
  case pokemonNotFound
  
  var errorDescription: String? {
    switch self {
    case .invalidPokemonId:
      return "Invalid Pokemon ID. ID must be greater than 0."
    case .invalidPokemonName:
      return "Invalid Pokemon name. Name cannot be empty."
    case .queryTooShort:
      return "Search query must be at least 2 characters long."
    case .pokemonNotFound:
      return "Pokemon not found."
    }
  }
}
