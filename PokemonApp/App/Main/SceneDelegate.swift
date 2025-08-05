//
//  SceneDelegate.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  private var appCoordinator: AppCoordinatorProtocol?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: windowScene)
    
    _ = DIContainer.shared
    
    if let window = window {
      appCoordinator = AppCoordinator(window: window)
      appCoordinator?.start()
    }
  }
}
