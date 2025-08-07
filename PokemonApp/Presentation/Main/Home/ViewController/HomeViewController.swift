//
//  HomeViewController.swift
//  PokemonApp
//
//  Created by  M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol HomeViewControllerDelegate: AnyObject {
  // Standard delegate methods
}

final class HomeViewController: BaseViewController<HomeViewModel> {
  
  weak var delegate: HomeViewControllerDelegate?
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.backgroundColor = UIColor(hex: Constants.Colors.background)
    return scrollView
  }()
  
  private lazy var contentView = UIView()
  
  private lazy var titleView = PokemonTitleView(
    title: Constants.Strings.Auth.loginTitle,
    subtitle: Constants.Strings.Auth.loginSubtitle
  )
  
  private lazy var searchTextField: PokemonTextField = {
    let textField = PokemonTextField(
      title: "",
      placeholder: "Search Pokémon..."
    )
    textField.keyboardType = .default
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.returnKeyType = .search
    return textField
  }()
  
  private lazy var pokemonCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 15
    layout.minimumInteritemSpacing = 15
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(PokemonCardCell.self, forCellWithReuseIdentifier: PokemonCardCell.identifier)
    return collectionView
  }()
  
  // MARK: - Data
  private let pokemonData = [
    PokemonCardData(name: "Pikachu", type: "Electric", emoji: "⚡", colors: ["#FFD700", "#FFA500"]),
    PokemonCardData(name: "Charmander", type: "Fire", emoji: "🔥", colors: ["#FF6B6B", "#FF4444"]),
    PokemonCardData(name: "Squirtle", type: "Water", emoji: "💧", colors: ["#4ECDC4", "#44A08D"]),
    PokemonCardData(name: "Bulbasaur", type: "Grass", emoji: "🌿", colors: ["#56AB2F", "#A8E6CF"]),
    PokemonCardData(name: "Pidgey", type: "Flying", emoji: "🦅", colors: ["#F093FB", "#F5576C"]),
    PokemonCardData(name: "Eevee", type: "Normal", emoji: "🐾", colors: ["#D299C2", "#FEF9E7"])
  ]
  
  private var filteredPokemon: [PokemonCardData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    filteredPokemon = pokemonData
  }
  
  override func setupUI() {
    view.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(titleView)
    contentView.addSubview(searchTextField)
    contentView.addSubview(pokemonCollectionView)
    
    setupConstraints()
    setupCollectionView()
  }
  
  private func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    // Ensure title starts with proper spacing
    titleView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    searchTextField.snp.makeConstraints { make in
      make.top.equalTo(titleView.snp.bottom).offset(Constants.Spacing.xl)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    pokemonCollectionView.snp.makeConstraints { make in
      make.top.equalTo(searchTextField.snp.bottom).offset(Constants.Spacing.xl)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
      make.height.equalTo(500) // Fixed height for now
      make.bottom.equalToSuperview().offset(-Constants.Spacing.xl)
    }
  }
  
  private func setupCollectionView() {
    // Update collection view layout for better spacing
    if let layout = pokemonCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = 12 // Reduced from 15
      layout.minimumInteritemSpacing = 8 // Reduced from 15
      layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    pokemonCollectionView.delegate = self
    pokemonCollectionView.dataSource = self
  }
  
  override func setupBindings() {
    // Search functionality
    searchTextField.rx_text.orEmpty
      .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] searchText in
        self?.filterPokemon(with: searchText)
      })
      .disposed(by: disposeBag)
  }
  
  private func filterPokemon(with searchText: String) {
    if searchText.isEmpty {
      filteredPokemon = pokemonData
    } else {
      filteredPokemon = pokemonData.filter { pokemon in
        pokemon.name.lowercased().contains(searchText.lowercased()) ||
        pokemon.type.lowercased().contains(searchText.lowercased())
      }
    }
    
    DispatchQueue.main.async {
      self.pokemonCollectionView.reloadData()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredPokemon.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCardCell.identifier, for: indexPath) as? PokemonCardCell else {
      return UICollectionViewCell()
    }
    
    let pokemon = filteredPokemon[indexPath.item]
    cell.configure(with: pokemon)
    return cell
  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let padding = Constants.Spacing.xl // left + right padding + minimumInteritemSpacing
    let availableWidth = collectionView.frame.width - padding
    let width = availableWidth / 2
    return CGSize(width: width, height: 140) // Reduced height from 140 to 120
  }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let pokemon = filteredPokemon[indexPath.item]
    print("Selected: \(pokemon.name)")
    // Handle pokemon selection - navigate to detail or show info
  }
}

// MARK: - Supporting Data Model
struct PokemonCardData {
  let name: String
  let type: String
  let emoji: String
  let colors: [String]
}
