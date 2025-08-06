//
//  DIContainer.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import Foundation
import Swinject

final class DIContainer {
  static let shared = DIContainer()
  
  let container: Container
  
  private init() {
    container = Container()
    registerDependencies()
  }
  
  private func registerDependencies() {
    let assemblies: [Assembly] = [
      NetworkAssembly(),
      DatabaseAssembly(),
      AppAssembly(),
      PresentationAssembly()
    ]
    
    assemblies.forEach { $0.assemble(container: container) }
  }
  
  func resolve<T>(_ serviceType: T.Type) -> T {
    guard let service = container.resolve(serviceType) else {
      fatalError("❌ Unable to resolve \(serviceType)")
    }
    return service
  }
}
