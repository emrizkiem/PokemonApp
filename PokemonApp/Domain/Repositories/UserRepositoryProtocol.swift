//
//  UserRepositoryProtocol.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift

protocol UserRepositoryProtocol {
  func loginUser(email: String, password: String) -> Observable<User?>
  func registerUser(email: String, fullName: String, password: String) -> Observable<User>
  func getCurrentUser() -> Observable<User?>
  func isUserLoggedIn() -> Bool
  func logoutUser() -> Observable<Void>
}
