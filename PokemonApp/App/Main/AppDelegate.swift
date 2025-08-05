//
//  AppDelegate.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    setupGlobalAppearance()
    
    return true
  }
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  private func setupGlobalAppearance() {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithOpaqueBackground()
    navBarAppearance.backgroundColor = UIColor(hex: Constants.Colors.primary) // Purple
    navBarAppearance.titleTextAttributes = [
      .foregroundColor: UIColor.white,
      .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
    ]
    navBarAppearance.largeTitleTextAttributes = [
      .foregroundColor: UIColor.white,
      .font: UIFont.systemFont(ofSize: 32, weight: .bold)
    ]
    
    UINavigationBar.appearance().standardAppearance = navBarAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    UINavigationBar.appearance().compactAppearance = navBarAppearance
    UINavigationBar.appearance().tintColor = UIColor.white
    
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = UIColor(hex: Constants.Colors.surfaceElevated)
    tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: Constants.Colors.primary)
    tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor(hex: Constants.Colors.primary)
    ]
    tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: Constants.Colors.textSecondaryOnSurface)
    tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor(hex: Constants.Colors.textSecondaryOnSurface)
    ]
    
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    UIWindow.appearance().tintColor = UIColor(hex: Constants.Colors.primary)
    UISearchBar.appearance().backgroundColor = UIColor(hex: Constants.Colors.backgroundLight)
    UISearchBar.appearance().tintColor = UIColor(hex: Constants.Colors.primary)
    UISearchBar.appearance().barTintColor = UIColor(hex: Constants.Colors.backgroundLight)
    UITextField.appearance().tintColor = UIColor(hex: Constants.Colors.primary)
    UIButton.appearance().tintColor = UIColor(hex: Constants.Colors.primary)
    UISwitch.appearance().onTintColor = UIColor(hex: Constants.Colors.primary)
    UIProgressView.appearance().progressTintColor = UIColor(hex: Constants.Colors.primary)
    UIProgressView.appearance().trackTintColor = UIColor(hex: Constants.Colors.border)
    UIActivityIndicatorView.appearance().color = UIColor(hex: Constants.Colors.primary)
    
    if #available(iOS 13.0, *) {
      UIApplication.shared.windows.forEach { window in
        window.overrideUserInterfaceStyle = .light
      }
    }
  }
}
