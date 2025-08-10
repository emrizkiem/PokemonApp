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
  func homeDidSelectPokemon(_ pokemon: Pokemon)
}

final class HomeViewController: BaseViewController<HomeViewModel> {
  
  weak var delegate: HomeViewControllerDelegate?
  
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
    layout.minimumLineSpacing = 12
    layout.minimumInteritemSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(PokemonCardCell.self, forCellWithReuseIdentifier: PokemonCardCell.identifier)
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor(hex: Constants.Colors.primary)
    return refreshControl
  }()
  
  private var pokemonList: [Pokemon] = []
  private var currentPaginationState: PaginationUIState = .idle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationCallbacks()
  }
  
  override func setupUI() {
    view.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    view.addSubview(titleView)
    view.addSubview(searchTextField)
    view.addSubview(pokemonCollectionView)
    
    pokemonCollectionView.refreshControl = refreshControl
    
    setupConstraints()
    setupCollectionView()
  }
  
  private func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    searchTextField.snp.makeConstraints { make in
      make.top.equalTo(titleView.snp.bottom).offset(Constants.Spacing.xl)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    pokemonCollectionView.snp.makeConstraints { make in
      make.top.equalTo(searchTextField.snp.bottom).offset(Constants.Spacing.xl)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func setupCollectionView() {
    pokemonCollectionView.delegate = self
    pokemonCollectionView.dataSource = self
  }
  
  private func setupNavigationCallbacks() {
    viewModel.onPokemonSelected = { [weak self] pokemon in
      self?.delegate?.homeDidSelectPokemon(pokemon)
    }
  }
  
  override func setupBindings() {
    searchTextField.rx_text.orEmpty
      .bind(to: viewModel.searchQuery)
      .disposed(by: disposeBag)
    
    refreshControl.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.refreshTrigger)
      .disposed(by: disposeBag)
    
    viewModel.pokemonList
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] pokemons in
        self?.pokemonList = pokemons
        self?.pokemonCollectionView.reloadData()
      })
      .disposed(by: disposeBag)
    
    viewModel.paginationState
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        self?.currentPaginationState = state
        self?.handlePaginationState(state)
      })
      .disposed(by: disposeBag)
    
    viewModel.isRefreshing
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isRefreshing in
        if !isRefreshing {
          self?.refreshControl.endRefreshing()
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func handlePaginationState(_ state: PaginationUIState) {
    switch state {
    case .empty:
      showEmptyState()
    case .error(let message):
      if pokemonList.isEmpty {
        showErrorAlert(message: message)
      } else {
        print("Error with existing data: \(message)")
      }
    default:
      break
    }
  }
  
  private func showEmptyState() {
    let searchQuery = viewModel.searchQuery.value
    let message = searchQuery.isEmpty ?
    "No Pokémon available. Please try again later." :
    "No Pokémon found for '\(searchQuery)'"
    
    showErrorAlert(message: message)
  }
  
  private func showErrorAlert(message: String) {
    let alert = UIAlertController(
      title: "No Results",
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pokemonList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: PokemonCardCell.identifier,
      for: indexPath
    ) as? PokemonCardCell else {
      return UICollectionViewCell()
    }
    
    let pokemon = pokemonList[indexPath.item]
    cell.configure(with: pokemon)
    
    if indexPath.item >= pokemonList.count - 5 && currentPaginationState.canLoadMore {
      viewModel.loadNextPageTrigger.onNext(())
    }
    
    return cell
  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let padding = Constants.Spacing.xl + 8
    let availableWidth = collectionView.frame.width - padding
    let width = availableWidth / 2
    return CGSize(width: width, height: 140)
  }
}


extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.selectPokemon(at: indexPath.item)
  }
}
