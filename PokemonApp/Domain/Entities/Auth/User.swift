//
//  User.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

struct User {
  let id: String
  let email: String
  let fullName: String
  let createdAt: Date
  
  init(id: String, email: String, fullName: String, createdAt: Date) {
    self.id = id
    self.email = email
    self.fullName = fullName
    self.createdAt = createdAt
  }
  
  var joinedDateFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: createdAt)
  }
  
  var initials: String {
    let names = fullName.split(separator: " ")
    let firstInitial = names.first?.first?.uppercased() ?? ""
    let lastInitial = names.count > 1 ? names.last?.first?.uppercased() ?? "" : ""
    return "\(firstInitial)\(lastInitial)"
  }
}
