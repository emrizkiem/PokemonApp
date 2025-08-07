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
    static let borderWidth: CGFloat = 1
    static let buttonHeight: CGFloat = 56
    static let textFieldHeight: CGFloat = 56
    static let headerHeight: CGFloat = 120
  }
  
  struct Colors {
    static let primary = "#7B68EE"
    static let secondary = "#B8A6A6"
    static let accent = "#FF6B6B"
    static let background = "#1A1A1A"
    static let cardBackground = "#2D2D2D"
    static let surfaceBackground = "#3A3A3A"
    static let backgroundLight = "f0f1ff"
    static let surface = "ffffff"
    static let surfaceElevated = "f8f9ff"
    static let textPrimary = "#FFFFFF"
    static let textSecondary = "#A0A0A0"
    static let textTertiary = "#7A7A7A"
    static let textSecondaryOnSurface = "666666"
    static let placeholder = "#6A6A6A"
    static let textFieldBackground = "#2D2D2D"
    static let textFieldBorder = "#404040"
    static let textFieldBorderFocused = "#7B68EE"
    static let textFieldText = "#FFFFFF"
    static let buttonPrimary = "#7B68EE"
    static let buttonSecondary = "transparent"
    static let buttonDisabled = "#555555"
    static let success = "#4CAF50"
    static let error = "#F44336"
    static let warning = "#FF9800"
    static let info = "#2196F3"
    static let border = "#404040"
    static let borderLight = "#505050"     
    static let borderDark = "#2A2A2A"
  }
  
  struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let huge: CGFloat = 40
  }
  
  struct Fonts {
    static let largeTitle: CGFloat = 48
    static let title: CGFloat = 24
    static let subtitle: CGFloat = 18
    static let body: CGFloat = 16
    static let caption: CGFloat = 14
  }
  
  struct Animation {
    static let duration: TimeInterval = 0.3
    static let springDamping: CGFloat = 0.8
    static let springVelocity: CGFloat = 0.5
  }
}

extension Constants {
  struct Strings {
    
    struct Auth {
      static let loginTitle = "Pokémon"
      static let loginSubtitle = "Catch 'em all!"
      static let registerTitle = "Pokémon"
      static let registerSubtitle = "Join the adventure!"
      
      static let email = "Email"
      static let password = "Password"
      static let fullName = "Full Name"
      
      static let emailPlaceholder = "user@example.com"
      static let passwordPlaceholder = "Password"
      static let fullNamePlaceholder = "John Doe"
      
      static let loginButton = "Login"
      static let registerButton = "Register"
      static let createAccountButton = "Create Account"
      static let backToLoginButton = "Back to Login"
      
      static let loginScreen = "Login Screen"
      static let registerScreen = "Register Screen"
    }
    
    struct Errors {
      static let loginFailed = "Login Failed"
      static let registrationFailed = "Registration Failed"
      static let genericError = "An unexpected error occurred. Please try again."
      static let networkError = "Network error. Please check your connection and try again."
    }
    
    struct Success {
      static let registrationSuccessful = "Registration Successful!"
      static let welcomeMessage = "Welcome to Pokémon"
    }
  }
}
