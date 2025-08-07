//
//  DatabaseService.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RxSwift
import RealmSwift

protocol DatabaseServiceProtocol {
  func registerUser(email: String, fullName: String, password: String) -> Observable<User>
  func loginUser(email: String, password: String) -> Observable<User?>
  func getUserById(userId: String) -> Observable<User?>
}

final class DatabaseService: DatabaseServiceProtocol {
  
  private let backgroundQueue = DispatchQueue(label: "realm.background", qos: .utility)
  
  init() throws {
    do {
      var config = Realm.Configuration.defaultConfiguration
      config.deleteRealmIfMigrationNeeded = true
      config.schemaVersion = 1
      config.fileURL = config.fileURL!.deletingLastPathComponent()
        .appendingPathComponent("PokemonApp.realm")
      
      _ = try Realm(configuration: config)
      
      print("💾 DatabaseService initialized successfully")
      print("📁 Database location: \(config.fileURL?.absoluteString ?? "unknown")")
    } catch {
      print("❌ Failed to initialize Realm: \(error)")
      throw DatabaseError.initializationFailed
    }
  }
  
  func registerUser(email: String, fullName: String, password: String) -> Observable<User> {
    return Observable.create { observer in
      self.backgroundQueue.async {
        do {
          let realm = try Realm()
          
          // Check if email already exists
          let existingUser = realm.objects(UserEntity.self)
            .filter("email == %@", email.lowercased()).first
          
          if existingUser != nil {
            DispatchQueue.main.async {
              print("❌ User already exists: \(email)")
              observer.onError(AuthError.userAlreadyExists)
            }
            return
          }
          
          // Create new user
          let userEntity = UserEntity(email: email, fullName: fullName, password: password)
          
          try realm.write {
            realm.add(userEntity, update: .modified)
          }
          
          // Convert to domain model
          let user = User(
            id: userEntity.id,
            email: userEntity.email,
            fullName: userEntity.fullName,
            createdAt: userEntity.createdAt
          )
          
          DispatchQueue.main.async {
            print("✅ User registered: \(user.email)")
            observer.onNext(user)
            observer.onCompleted()
          }
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to register user: \(error)")
            observer.onError(DatabaseError.saveFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func loginUser(email: String, password: String) -> Observable<User?> {
    return Observable.create { observer in
      self.backgroundQueue.async {
        do {
          let realm = try Realm()
          
          // Find user with matching email and password
          let userEntity = realm.objects(UserEntity.self)
            .filter("email == %@ AND password == %@ AND isActive == true",
                    email.lowercased(), password)
            .first
          
          if let userEntity = userEntity {
            // Convert to domain model
            let user = User(
              id: userEntity.id,
              email: userEntity.email,
              fullName: userEntity.fullName,
              createdAt: userEntity.createdAt
            )
            
            DispatchQueue.main.async {
              print("✅ User logged in: \(user.email)")
              observer.onNext(user)
              observer.onCompleted()
            }
          } else {
            DispatchQueue.main.async {
              print("❌ Invalid credentials for: \(email)")
              observer.onNext(nil)
              observer.onCompleted()
            }
          }
        } catch {
          DispatchQueue.main.async {
            print("❌ Login error: \(error)")
            observer.onError(DatabaseError.queryFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func getUserById(userId: String) -> Observable<User?> {
    return Observable.create { observer in
      self.backgroundQueue.async {
        do {
          let realm = try Realm()
          
          if let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId),
             userEntity.isActive {
            
            let user = User(
              id: userEntity.id,
              email: userEntity.email,
              fullName: userEntity.fullName,
              createdAt: userEntity.createdAt
            )
            
            DispatchQueue.main.async {
              print("✅ Found user: \(user.email)")
              observer.onNext(user)
              observer.onCompleted()
            }
          } else {
            DispatchQueue.main.async {
              print("❌ User not found: \(userId)")
              observer.onNext(nil)
              observer.onCompleted()
            }
          }
        } catch {
          DispatchQueue.main.async {
            print("❌ Error getting user: \(error)")
            observer.onError(DatabaseError.queryFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
}
