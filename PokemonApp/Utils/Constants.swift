//
//  Constants.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import UIKit

struct Constants {
  struct App {
    static let name = "Pokémon"
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
  }
  
  struct API {
    static let baseURL = "https://pokeapi.co/api/v2"
    static let timeoutInterval: TimeInterval = 30
    static let pokemonPerPage = 10
  }
  
  struct UI {
    static let animationDuration: TimeInterval = 0.3
    static let cornerRadius: CGFloat = 12
    static let shadowOpacity: Float = 0.1
    static let shadowRadius: CGFloat = 4
    static let shadowOffset = CGSize(width: 0, height: 2)
  }
  
  struct Colors {
    static let primary = "667eea"
    static let secondary = "764ba2"
    static let accent = "ff6b6b"
    static let success = "4ecdc4"
    static let warning = "ffa726"
    static let error = "ef5350"
    static let background = "f8f9fa"
    static let backgroundLight = "f0f1ff"
    static let surface = "ffffff"
    static let surfaceElevated = "f8f9ff"
    static let text = "333333"
    static let textSecondary = "666666"
    static let textTertiary = "c4c7ff"    
    static let textOnSurface = "333333"
    static let textSecondaryOnSurface = "666666"
    static let border = "e0e0e0"
  }
  
  struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
  }
}
