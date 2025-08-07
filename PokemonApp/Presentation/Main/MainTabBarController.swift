//
//  MainTabBarController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
  
  init(pages: [UIViewController]) {
    super.init(nibName: nil, bundle: nil)
    setupViewControllers(pages)
    setupDarkTheme()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    // Status bar styling
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .dark
    }
  }
  
  private func setupViewControllers(_ pages: [UIViewController]) {
    // Setup tab bar items
    if pages.count >= 1 {
      pages[0].tabBarItem = UITabBarItem(
        title: "Home",
        image: UIImage(systemName: "house"),
        selectedImage: UIImage(systemName: "house.fill")
      )
    }
    
    if pages.count >= 2 {
      pages[1].tabBarItem = UITabBarItem(
        title: "Profile",
        image: UIImage(systemName: "person"),
        selectedImage: UIImage(systemName: "person.fill")
      )
    }
    
    viewControllers = pages
  }
  
  private func setupDarkTheme() {
    // Tab bar appearance
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    // Normal state
    tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
    tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.white.withAlphaComponent(0.6),
      .font: UIFont.systemFont(ofSize: 12, weight: .medium)
    ]
    
    // Selected state
    tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: Constants.Colors.primary)
    tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor(hex: Constants.Colors.primary),
      .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
    ]
    
    // Apply appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    tabBar.standardAppearance = tabBarAppearance
    
    // Additional styling
    tabBar.tintColor = UIColor(hex: Constants.Colors.primary)
    tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
    tabBar.barTintColor = UIColor(hex: Constants.Colors.background)
    tabBar.isTranslucent = false
  }
}
