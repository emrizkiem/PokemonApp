//
//  NetworkError.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingError(Error)
  case networkError(Error)
  case serverError(Int)
  case timeout
  case noInternetConnection
  case unauthorized
  case forbidden
  case notFound
  case unknown
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .noData:
      return "No data received"
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .serverError(let code):
      return "Server error with status code: \(code)"
    case .timeout:
      return "Request timeout"
    case .noInternetConnection:
      return "No internet connection"
    case .unauthorized:
      return "Unauthorized access"
    case .forbidden:
      return "Access forbidden"
    case .notFound:
      return "Resource not found"
    case .unknown:
      return "Unknown error occurred"
    }
  }
}
