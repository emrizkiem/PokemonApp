//
//  ValidationUtils.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

final class ValidationUtils {
  
  private init() {}
  
  static func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    let isValid = emailPredicate.evaluate(with: email)
    
    if !isValid {
      print("⚠️ ValidationUtils: Invalid email format - \(email)")
    }
    
    return isValid
  }
  
  static func isValidPassword(_ password: String) -> Bool {
    let isValid = password.count >= 6
    
    if !isValid {
      print("⚠️ ValidationUtils: Password too weak - \(password.count) characters")
    }
    
    return isValid
  }
  
  static func cleanString(_ input: String) -> String {
    return input.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  static func cleanEmail(_ email: String) -> String {
    return cleanString(email).lowercased()
  }
  
  static func cleanFullName(_ fullName: String) -> String {
    return cleanString(fullName)
  }
  
  static func isNotEmpty(_ string: String) -> Bool {
    return !cleanString(string).isEmpty
  }
}
