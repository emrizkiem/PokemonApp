//
//  User.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation

struct User: Codable, Equatable {
  let id: String
  let email: String
  let fullName: String
  var accessToken: String?
  let createdAt: Date?
  
  init(id: String = UUID().uuidString, email: String, fullName: String, accessToken: String? = nil, createdAt: Date? = Date()) {
    self.id = id
    self.email = email
    self.fullName = fullName
    self.accessToken = accessToken
    self.createdAt = createdAt
  }
  
  var initials: String {
    let components = fullName.split(separator: " ")
    let initials = components.compactMap { $0.first }.map { String($0) }.joined()
    return String(initials.prefix(2)).uppercased()
  }
  
  var joinedDateString: String {
    guard let createdAt = createdAt else { return "Unknown" }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: createdAt)
  }
}
