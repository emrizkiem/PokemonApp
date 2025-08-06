//
//  DatabaseService.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import RealmSwift
import RxSwift

protocol DatabaseServiceProtocol {
  // MARK: 💾 CREATE/SAVE Operations
  func store<T: Object>(_ object: T) -> Observable<Void>
  func storeBatch<T: Object>(_ objects: [T]) -> Observable<Void>
  
  // MARK: 📖 READ Operations
  func getAll<T: Object>(_ type: T.Type) -> Observable<[T]>
  func find<T: Object>(_ type: T.Type, where predicate: NSPredicate) -> Observable<[T]>
  func findFirst<T: Object>(_ type: T.Type, where predicate: NSPredicate) -> Observable<T?>
  
  // MARK: 🗑️ DELETE Operations
  func remove<T: Object>(_ object: T) -> Observable<Void>
  func removeWhere<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Observable<Void>
  func removeAll<T: Object>(_ type: T.Type) -> Observable<Void>
}

final class DatabaseService: DatabaseServiceProtocol {
  
  private let realm: Realm
  private let backgroundQueue = DispatchQueue(label: "realm.background", qos: .utility)
  
  init() throws {
    do {
      // Configure Realm
      var config = Realm.Configuration.defaultConfiguration
      
      // Set schema version and migration block
      config.schemaVersion = 1
      config.migrationBlock = { migration, oldSchemaVersion in
        // Handle migrations here if needed
        print("💾 Realm migration from version \(oldSchemaVersion)")
      }
      
      // Set file URL
      config.fileURL = config.fileURL!.deletingLastPathComponent()
        .appendingPathComponent("PokemonApp.realm")
      
      realm = try Realm(configuration: config)
      
      print("💾 RealmManager initialized successfully")
      print("📁 Database location: \(config.fileURL?.absoluteString ?? "unknown")")
      
    } catch {
      print("❌ Failed to initialize Realm: \(error)")
      throw DatabaseError.initializationFailed
    }
  }
  
  func store<T: Object>(_ object: T) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          try realm.write {
            realm.add(object, update: .modified)
          }
          
          DispatchQueue.main.async {
            print("✅ Stored object: \(String(describing: T.self))")
            observer.onNext(())
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to store object: \(error)")
            observer.onError(DatabaseError.saveFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func storeBatch<T: Object>(_ objects: [T]) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          try realm.write {
            realm.add(objects, update: .modified)
          }
          
          DispatchQueue.main.async {
            print("✅ Stored batch of \(objects.count) objects: \(String(describing: T.self))")
            observer.onNext(())
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to store batch: \(error)")
            observer.onError(DatabaseError.saveFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func getAll<T: Object>(_ type: T.Type) -> Observable<[T]> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          let results = Array(realm.objects(type))
          
          DispatchQueue.main.async {
            print("✅ Retrieved all \(results.count) objects: \(String(describing: type))")
            observer.onNext(results)
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to get all objects: \(error)")
            observer.onError(DatabaseError.queryFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func find<T: Object>(_ type: T.Type, where predicate: NSPredicate) -> Observable<[T]> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          let results = Array(realm.objects(type).filter(predicate))
          
          DispatchQueue.main.async {
            print("✅ Found \(results.count) objects matching criteria: \(String(describing: type))")
            observer.onNext(results)
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to find objects: \(error)")
            observer.onError(DatabaseError.queryFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func findFirst<T: Object>(_ type: T.Type, where predicate: NSPredicate) -> Observable<T?> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          let result = realm.objects(type).filter(predicate).first
          
          DispatchQueue.main.async {
            print("✅ Found first object: \(String(describing: type))")
            observer.onNext(result)
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to find first object: \(error)")
            observer.onError(DatabaseError.queryFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func remove<T: Object>(_ object: T) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          try realm.write {
            realm.delete(object)
          }
          
          DispatchQueue.main.async {
            print("✅ Removed object: \(String(describing: T.self))")
            observer.onNext(())
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to remove object: \(error)")
            observer.onError(DatabaseError.deleteFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func removeWhere<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          let objectsToDelete = realm.objects(type).filter(predicate)
          let count = objectsToDelete.count
          
          try realm.write {
            realm.delete(objectsToDelete)
          }
          
          DispatchQueue.main.async {
            print("✅ Removed \(count) objects matching criteria: \(String(describing: type))")
            observer.onNext(())
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to remove objects: \(error)")
            observer.onError(DatabaseError.deleteFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func removeAll<T: Object>(_ type: T.Type) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      self?.backgroundQueue.async {
        do {
          let realm = try Realm()
          let objectsToDelete = realm.objects(type)
          let count = objectsToDelete.count
          
          try realm.write {
            realm.delete(objectsToDelete)
          }
          
          DispatchQueue.main.async {
            print("✅ Removed all \(count) objects: \(String(describing: type))")
            observer.onNext(())
            observer.onCompleted()
          }
          
        } catch {
          DispatchQueue.main.async {
            print("❌ Failed to remove all objects: \(error)")
            observer.onError(DatabaseError.deleteFailed(error))
          }
        }
      }
      
      return Disposables.create()
    }
  }
}
