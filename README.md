# PokemonApp
An iOS app that displays Pokemon based on the list of PokeApi using Swift and UIKit.

![Swift](https://img.shields.io/badge/Swift-Compatible-orange?style=flat-square)
![UIKit](https://img.shields.io/badge/UIKit-Component-green?style=flat-square)

### Architecture
The project use MVVM (Model View ViewModel):
1. Presentation layer: View & ViewModel
2. Domain layer: Entities & UseCase & Repository
3. Data layer: Repository & Data Source (Remote or Database)
4. Dependency Injection

### Tech Stack
1. Swift + UIKit
2. Reactive Programming with RxSwift
3. Alamofire for network request
4. Swinject for dependency injection
5. Realm for local storage

## Getting Started
### Requirement
- iOS 14.0+
- XCode 15.0+
- Swift 5.0+
- CocoaPods

### Installation
1. To use this project you must do clone 
2. Install dependencies with CocoaPods
```swift
pod install
```
