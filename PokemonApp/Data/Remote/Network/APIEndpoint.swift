//
//  APIEndpoint.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

protocol APIEndpoint {
  var baseURL: String { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String]? { get }
  var parameters: [String: Any]? { get }
  var queryItems: [URLQueryItem]? { get }
}

enum HTTPMethod: String {
  case GET = "GET"
  case POST = "POST"
  case PUT = "PUT"
  case DELETE = "DELETE"
}

enum PokemonEndpoint: APIEndpoint {
  case pokemonList(limit: Int, offset: Int)
  case pokemonDetail(id: Int)
  case pokemonByName(name: String)
  case pokemonSpecies(id: Int)
  case pokemonAbility(id: Int)
  
  var baseURL: String {
    return Constants.API.baseURL
  }
  
  var path: String {
    switch self {
    case .pokemonList:
      return "/pokemon"
    case .pokemonDetail(let id):
      return "/pokemon/\(id)"
    case .pokemonByName(let name):
      return "/pokemon/\(name.lowercased())"
    case .pokemonSpecies(let id):
      return "/pokemon-species/\(id)"
    case .pokemonAbility(let id):
      return "/ability/\(id)"
    }
  }
  
  var method: HTTPMethod {
    return .GET
  }
  
  var headers: [String: String]? {
    return [
      "Content-Type": "application/json",
      "Accept": "application/json"
    ]
  }
  
  var parameters: [String: Any]? {
    return nil
  }
  
  var queryItems: [URLQueryItem]? {
    switch self {
    case .pokemonList(let limit, let offset):
      return [
        URLQueryItem(name: "limit", value: "\(limit)"),
        URLQueryItem(name: "offset", value: "\(offset)")
      ]
    default:
      return nil
    }
  }
}
