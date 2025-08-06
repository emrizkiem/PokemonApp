//
//  DatabaseError.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

enum DatabaseError: Error, LocalizedError {
  case initializationFailed
  case objectNotFound
  case saveFailed(Error)
  case deleteFailed(Error)
  case queryFailed(Error)
  case invalidObject
  case constraintViolation(String)
  case unknown(Error)
  
  var errorDescription: String? {
    switch self {
    case .initializationFailed:
      return "Failed to initialize database"
    case .objectNotFound:
      return "Object not found in database"
    case .saveFailed(let error):
      return "Failed to save object: \(error.localizedDescription)"
    case .deleteFailed(let error):
      return "Failed to delete object: \(error.localizedDescription)"
    case .queryFailed(let error):
      return "Failed to query database: \(error.localizedDescription)"
    case .invalidObject:
      return "Invalid object provided"
    case .constraintViolation(let message):
      return "Constraint violation: \(message)"
    case .unknown(let error):
      return "Unknown database error: \(error.localizedDescription)"
    }
  }
}
