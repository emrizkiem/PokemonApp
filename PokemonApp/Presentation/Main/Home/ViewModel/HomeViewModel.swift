//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import Foundation
import RxSwift
import RxRelay

enum PaginationUIState: Equatable {
  case idle
  case loading
  case loadingMore
  case error(String)
  case empty
  
  var isLoading: Bool {
    switch self {
    case .loading, .loadingMore:
      return true
    default:
      return false
    }
  }
  
  var canLoadMore: Bool {
    switch self {
    case .idle:
      return true
    default:
      return false
    }
  }
}

protocol HomeViewModelProtocol: BaseViewModelProtocol {
  var searchQuery: BehaviorRelay<String> { get }
  var loadNextPageTrigger: PublishSubject<Void> { get }
  var refreshTrigger: PublishSubject<Void> { get }
  
  var pokemonList: BehaviorRelay<[Pokemon]> { get }
  var paginationState: BehaviorRelay<PaginationUIState> { get }
  var isRefreshing: BehaviorRelay<Bool> { get }
  
  func loadInitialData()
  func loadNextPage()
  func refresh()
  func searchPokemon(_ query: String)
  func selectPokemon(at index: Int)
}

final class HomeViewModel: BaseViewModel, HomeViewModelProtocol {
  
  private let pokemonUseCase: PokemonUseCaseProtocol
  
  let searchQuery = BehaviorRelay<String>(value: "")
  let loadNextPageTrigger = PublishSubject<Void>()
  let refreshTrigger = PublishSubject<Void>()
  
  let pokemonList = BehaviorRelay<[Pokemon]>(value: [])
  let paginationState = BehaviorRelay<PaginationUIState>(value: .idle)
  let isRefreshing = BehaviorRelay<Bool>(value: false)
  
  private var currentPaginationState = PaginationState.initial
  private var isSearchMode = false
  
  var onPokemonSelected: ((Pokemon) -> Void)?

  init(pokemonUseCase: PokemonUseCaseProtocol) {
    self.pokemonUseCase = pokemonUseCase
    super.init()
    setupBindings()
  }
  
  override func initialize() {
    super.initialize()
    loadInitialData()
  }
  
  private func setupBindings() {
    searchQuery
      .skip(1)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] query in
        self?.handleSearchQuery(query)
      })
      .disposed(by: disposeBag)
    
    loadNextPageTrigger
      .filter { [weak self] in
        guard let self = self else { return false }
        return self.paginationState.value.canLoadMore &&
        !self.isSearchMode &&
        self.currentPaginationState.canLoadMore
      }
      .subscribe(onNext: { [weak self] in
        self?.loadNextPage()
      })
      .disposed(by: disposeBag)
    
    refreshTrigger
      .subscribe(onNext: { [weak self] in
        self?.refresh()
      })
      .disposed(by: disposeBag)
  }
  
  func loadInitialData() {
    guard !paginationState.value.isLoading else {
      return
    }
    
    guard pokemonList.value.isEmpty || isSearchMode else {
      return
    }
    
    paginationState.accept(.loading)
    currentPaginationState = PaginationState.initial
    isSearchMode = false
    
    pokemonUseCase.fetchPokemonList(limit: currentPaginationState.limit, offset: 0)
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] page in
          self?.handlePokemonPageResult(page, isInitial: true)
        },
        onError: { [weak self] error in
          self?.handlePokemonError(error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func loadNextPage() {
    guard currentPaginationState.canLoadMore && !isSearchMode else { return }
    
    paginationState.accept(.loadingMore)
    
    pokemonUseCase.fetchPokemonList(
      limit: currentPaginationState.limit,
      offset: currentPaginationState.nextOffset
    )
    .observe(on: MainScheduler.instance)
    .subscribe(
      onNext: { [weak self] page in
        self?.handlePokemonPageResult(page, isInitial: false)
      },
      onError: { [weak self] error in
        self?.handlePokemonError(error)
      }
    )
    .disposed(by: disposeBag)
  }
  
  func refresh() {
    isRefreshing.accept(true)
    currentPaginationState = PaginationState.initial
    isSearchMode = false
    searchQuery.accept("")
    
    if pokemonUseCase is PokemonUseCase {
      pokemonUseCase.fetchPokemonList(limit: currentPaginationState.limit, offset: 0)
        .observe(on: MainScheduler.instance)
        .subscribe(
          onNext: { [weak self] page in
            self?.isRefreshing.accept(false)
            self?.handlePokemonPageResult(page, isInitial: true)
          },
          onError: { [weak self] error in
            self?.isRefreshing.accept(false)
            self?.handlePokemonError(error)
          }
        )
        .disposed(by: disposeBag)
    }
  }
  
  func searchPokemon(_ query: String) {
    searchQuery.accept(query)
  }
  
  func selectPokemon(at index: Int) {
    let currentPokemons = pokemonList.value
    guard index < currentPokemons.count else { return }
    
    let selectedPokemon = currentPokemons[index]
    onPokemonSelected?(selectedPokemon)
  }
  
  private func handleSearchQuery(_ query: String) {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedQuery.isEmpty {
      isSearchMode = false
      
      pokemonList.accept([])
      paginationState.accept(.loading)
      currentPaginationState = PaginationState.initial
      
      pokemonUseCase.fetchPokemonList(limit: currentPaginationState.limit, offset: 0)
        .observe(on: MainScheduler.instance)
        .subscribe(
          onNext: { [weak self] page in
            self?.handlePokemonPageResult(page, isInitial: true)
          },
          onError: { [weak self] error in
            self?.handlePokemonError(error)
          }
        )
        .disposed(by: disposeBag)
      
      return
    }
    
    guard trimmedQuery.count >= 3 else {
      paginationState.accept(.error("Search query must be at least 2 characters"))
      return
    }
    
    isSearchMode = true
    paginationState.accept(.loading)
    
    pokemonUseCase.searchPokemon(trimmedQuery, limit: 50, offset: 0)
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] page in
          self?.pokemonList.accept(page.pokemons)
          self?.paginationState.accept(page.pokemons.isEmpty ? .empty : .idle)
        },
        onError: { [weak self] error in
          self?.handleSearchError(error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func handlePokemonPageResult(_ page: PokemonPage, isInitial: Bool) {
    currentPaginationState = PaginationState(
      currentOffset: page.currentOffset,
      limit: page.currentLimit,
      isLoading: false,
      hasNextPage: page.hasNextPage,
      totalCount: page.totalCount
    )
    
    if isInitial {
      pokemonList.accept(page.pokemons)
    } else {
      let updatedList = pokemonList.value + page.pokemons
      pokemonList.accept(updatedList)
    }
    
    if pokemonList.value.isEmpty {
      paginationState.accept(.empty)
    } else {
      paginationState.accept(.idle)
    }
  }
  
  private func handleSearchError(_ error: Error) {
    let errorMessage = errorMessage(from: error)
    paginationState.accept(.error(errorMessage))
    pokemonList.accept([])
  }
  
  private func handlePokemonError(_ error: Error) {
    let errorMessage = errorMessage(from: error)
    paginationState.accept(.error(errorMessage))
    
    if pokemonList.value.isEmpty {
      handleError(error)
    }
  }
  
  private func errorMessage(from error: Error) -> String {
    if let pokemonError = error as? PokemonError {
      return pokemonError.errorDescription ?? "Unknown error occurred"
    }
    
    return error.localizedDescription
  }
}
