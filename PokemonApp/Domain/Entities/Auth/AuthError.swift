//
//  AuthError.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

enum AuthError: Error, LocalizedError {
  case userAlreadyExists
  case invalidCredentials
  case userNotFound
  case weakPassword
  case invalidEmail
  case invalidFullName
  case registrationFailed
  case loginFailed
  case sessionExpired
  case userNotActive
  
  var errorDescription: String? {
    switch self {
    case .userAlreadyExists:
      return "User with this email already exists"
    case .invalidCredentials:
      return "Invalid email or password"
    case .userNotFound:
      return "User not found"
    case .weakPassword:
      return "Password must be at least 6 characters"
    case .invalidEmail:
      return "Please enter a valid email address"
    case .invalidFullName:
      return "Full name must be between 2-50 characters"
    case .registrationFailed:
      return "Registration failed. Please try again"
    case .loginFailed:
      return "Login failed. Please try again"
    case .sessionExpired:
      return "Session expired. Please login again"
    case .userNotActive:
      return "User account is deactivated"
    }
  }
}
