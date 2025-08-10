//
//  Pokemon.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation

struct Pokemon: Equatable {
  let id: Int
  let name: String
  let height: Int
  let weight: Int
  let baseExperience: Int
  let imageURL: String?
  let types: [String]
  let abilities: [String]
  let stats: [PokemonStatData]
  
  var displayName: String {
    return name.capitalized
  }
  
  var primaryType: String {
    return types.first?.capitalized ?? "Unknown"
  }
  
  var heightInMeters: Double {
    return Double(height) / 10.0
  }
  
  var weightInKg: Double {
    return Double(weight) / 10.0
  }
  
  var typeColors: [String] {
    return types.map { PokemonTypeColor.color(for: $0) }
  }
}

struct PokemonStatData: Equatable {
  let name: String
  let baseStat: Int
  let effort: Int
  
  var displayName: String {
    switch name {
    case "hp": return "HP"
    case "attack": return "Attack"
    case "defense": return "Defense"
    case "special-attack": return "Sp. Attack"
    case "special-defense": return "Sp. Defense"
    case "speed": return "Speed"
    default: return name.capitalized
    }
  }
}

struct PokemonPage {
  let pokemons: [Pokemon]
  let totalCount: Int
  let hasNextPage: Bool
  let hasPreviousPage: Bool
  let currentOffset: Int
  let currentLimit: Int
}

struct PaginationState {
  let currentOffset: Int
  let limit: Int
  let isLoading: Bool
  let hasNextPage: Bool
  let totalCount: Int
  
  var nextOffset: Int {
    return currentOffset + limit
  }
  
  var canLoadMore: Bool {
    return hasNextPage && !isLoading
  }
  
  static let initial = PaginationState(
    currentOffset: 0,
    limit: 20,
    isLoading: false,
    hasNextPage: true,
    totalCount: 0
  )
}

struct PokemonTypeColor {
  static func color(for type: String) -> String {
    switch type.lowercased() {
    case "normal": return "#A8A878"
    case "fire": return "#F08030"
    case "water": return "#6890F0"
    case "electric": return "#F8D030"
    case "grass": return "#78C850"
    case "ice": return "#98D8D8"
    case "fighting": return "#C03028"
    case "poison": return "#A040A0"
    case "ground": return "#E0C068"
    case "flying": return "#A890F0"
    case "psychic": return "#F85888"
    case "bug": return "#A8B820"
    case "rock": return "#B8A038"
    case "ghost": return "#705898"
    case "dragon": return "#7038F8"
    case "dark": return "#705848"
    case "steel": return "#B8B8D0"
    case "fairy": return "#EE99AC"
    default: return "#68A090"
    }
  }
}
