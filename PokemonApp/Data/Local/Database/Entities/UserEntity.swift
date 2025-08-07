//
//  UserEntity.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RealmSwift

final class UserEntity: Object {
  @Persisted var id: String = UUID().uuidString
  @Persisted var email: String = ""
  @Persisted var fullName: String = ""
  @Persisted var password: String = ""
  @Persisted var createdAt: Date = Date()
  @Persisted var isActive: Bool = true
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(email: String, fullName: String, password: String) {
    self.init()
    self.email = email.lowercased()
    self.fullName = fullName
    self.password = password
    self.createdAt = Date()
    self.isActive = true
  }
}
