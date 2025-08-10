//
//  PokemonAPI.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 08/08/25.
//

import Foundation

// MARK: - API Response Models (Data Transfer Objects)
struct PokemonListResponse: Codable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [PokemonListItem]
}

struct PokemonListItem: Codable {
  let name: String
  let url: String
  
  // Computed property to extract ID from URL
  var id: Int? {
    let components = url.components(separatedBy: "/")
    if let idString = components.dropLast().last, let id = Int(idString) {
      return id
    }
    return nil
  }
}

// MARK: - Pokemon Detail Response
struct PokemonDetailResponse: Codable {
  let id: Int
  let name: String
  let height: Int
  let weight: Int
  let baseExperience: Int?
  let sprites: PokemonSprites
  let types: [PokemonTypeSlot]
  let abilities: [PokemonAbilitySlot]
  let stats: [PokemonStat]
  
  enum CodingKeys: String, CodingKey {
    case id, name, height, weight, sprites, types, abilities, stats
    case baseExperience = "base_experience"
  }
}

struct PokemonSprites: Codable {
  let frontDefault: String?
  let frontShiny: String?
  let backDefault: String?
  let other: PokemonSpritesOther?
  
  enum CodingKeys: String, CodingKey {
    case frontDefault = "front_default"
    case frontShiny = "front_shiny"
    case backDefault = "back_default"
    case other
  }
}

struct PokemonSpritesOther: Codable {
  let officialArtwork: PokemonOfficialArtwork?
  
  enum CodingKeys: String, CodingKey {
    case officialArtwork = "official-artwork"
  }
}

struct PokemonOfficialArtwork: Codable {
  let frontDefault: String?
  
  enum CodingKeys: String, CodingKey {
    case frontDefault = "front_default"
  }
}

struct PokemonTypeSlot: Codable {
  let slot: Int
  let type: PokemonType
}

struct PokemonType: Codable {
  let name: String
  let url: String
}

struct PokemonAbilitySlot: Codable {
  let slot: Int
  let isHidden: Bool
  let ability: PokemonAbility
  
  enum CodingKeys: String, CodingKey {
    case slot, ability
    case isHidden = "is_hidden"
  }
}

struct PokemonAbility: Codable {
  let name: String
  let url: String
}

struct PokemonStat: Codable {
  let baseStat: Int
  let effort: Int
  let stat: PokemonStatInfo
  
  enum CodingKeys: String, CodingKey {
    case effort, stat
    case baseStat = "base_stat"
  }
}

struct PokemonStatInfo: Codable {
  let name: String
  let url: String
}

// MARK: - Mapping Extensions (Data -> Domain)
extension PokemonDetailResponse {
  func toDomain() -> Pokemon {
    return Pokemon(
      id: id,
      name: name,
      height: height,
      weight: weight,
      baseExperience: baseExperience ?? 0,
      imageURL: sprites.other?.officialArtwork?.frontDefault ?? sprites.frontDefault,
      types: types.map { $0.type.name },
      abilities: abilities.map { $0.ability.name },
      stats: stats.map { stat in
        PokemonStatData(
          name: stat.stat.name,
          baseStat: stat.baseStat,
          effort: stat.effort
        )
      }
    )
  }
}

extension PokemonListItem {
  func toSimplePokemon() -> Pokemon? {
    guard let pokemonId = id else { return nil }
    
    return Pokemon(
      id: pokemonId,
      name: name,
      height: 0, // Will be fetched later if needed
      weight: 0, // Will be fetched later if needed
      baseExperience: 0,
      imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId).png",
      types: [], // Will be fetched later if needed
      abilities: [],
      stats: []
    )
  }
}
