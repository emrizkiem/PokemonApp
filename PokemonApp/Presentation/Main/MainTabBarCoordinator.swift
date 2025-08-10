//
//  MainTabBarCoordinator.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import Swinject

protocol MainTabBarCoordinatorProtocol {
  var delegate: MainTabBarCoordinatorDelegate? { get set }
  func start(navigationController: UINavigationController)
  func showLogout()
}

protocol MainTabBarCoordinatorDelegate: AnyObject {
  func mainAppDidLogout()
}

final class MainTabBarCoordinator: MainTabBarCoordinatorProtocol {
  
  weak var delegate: MainTabBarCoordinatorDelegate?
  private let container: Resolver
  private let user: User
  private var navigationController: UINavigationController?
  
  private lazy var userDefaultsManager: UserDefaultsManagerProtocol = {
    return container.resolve(UserDefaultsManagerProtocol.self)!
  }()
  
  init(container: Resolver, user: User) {
    self.container = container
    self.user = user
  }
  
  func start(navigationController: UINavigationController) {
    self.navigationController = navigationController
    setupMainInterface()
  }
  
  private func setupMainInterface() {
    guard let navigationController = navigationController else { return }
    
    let homeVC = createHomeViewController()
    let profileVC = createProfileViewController()
    let tabBarController = MainTabBarController(pages: [homeVC, profileVC])
    
    navigationController.setViewControllers([tabBarController], animated: false)
  }
  
  private func createHomeViewController() -> HomeViewController {
    guard let homeViewController = container.resolve(HomeViewController.self) else {
      fatalError("❌ Failed to resolve HomeViewController from DI container")
    }
    
    guard homeViewController.viewModel != nil else {
      fatalError("❌ HomeViewController created without ViewModel injection")
    }
    
    homeViewController.delegate = self
    return homeViewController
  }
  
  private func createProfileViewController() -> ProfileViewController {
    guard let profileViewController = container.resolve(ProfileViewController.self) else {
      fatalError("❌ Failed to resolve ProfileViewController from DI container")
    }
    
    guard profileViewController.viewModel != nil else {
      fatalError("❌ ProfileViewController created without ViewModel injection")
    }
    
    profileViewController.user = user
    profileViewController.delegate = self
    return profileViewController
  }
  
  func showLogout() {
    let alert = UIAlertController(
      title: "Logout",
      message: "Are you sure you want to logout?",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
      self?.handleLogout()
    })
    
    navigationController?.present(alert, animated: true)
  }
  
  private func handleLogout() {
    userDefaultsManager.clearUserSession()
    delegate?.mainAppDidLogout()
  }
  
  private func showPokemonDetail(_ pokemon: Pokemon) {
    let pokemonDetailVC = createPokemonDetailViewController(pokemon: pokemon)
    
    let detailNavigationController = UINavigationController(rootViewController: pokemonDetailVC)
    detailNavigationController.modalPresentationStyle = .fullScreen
    detailNavigationController.modalTransitionStyle = .coverVertical
    detailNavigationController.isNavigationBarHidden = true
    
    navigationController?.present(detailNavigationController, animated: true) {
      print("✅ Pokemon detail presented successfully")
    }
  }
  
  private func createPokemonDetailViewController(pokemon: Pokemon) -> PokemonDetailViewController {
    guard let factory = container.resolve(PokemonDetailViewControllerFactory.self) else {
      fatalError("❌ Failed to resolve PokemonDetailViewControllerFactory from DI container")
    }
    
    let pokemonDetailVC = factory.createPokemonDetailViewController(pokemon: pokemon)
    
    pokemonDetailVC.viewModel?.onClose = { [weak self] in
      self?.navigationController?.dismiss(animated: true) {
        print("✅ Pokemon detail dismissed successfully")
      }
    }
    
    return pokemonDetailVC
  }
}

extension MainTabBarCoordinator: HomeViewControllerDelegate {
  func homeDidSelectPokemon(_ pokemon: Pokemon) {
    showPokemonDetail(pokemon)
  }
}

extension MainTabBarCoordinator: ProfileViewControllerDelegate {
  func profileDidRequestLogout() {
    showLogout()
  }
}
