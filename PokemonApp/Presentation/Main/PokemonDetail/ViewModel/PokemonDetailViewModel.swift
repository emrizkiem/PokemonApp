//
//  PokemonDetailViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 10/08/25.
//

import Foundation
import RxSwift
import RxRelay

protocol PokemonDetailViewModelProtocol: BaseViewModelProtocol {
  var loadDetailTrigger: PublishSubject<Void> { get }
  var closeTrigger: PublishSubject<Void> { get }
  
  var pokemonDetail: BehaviorRelay<Pokemon?> { get }

  func loadPokemonDetail()
  func close()
}

final class PokemonDetailViewModel: BaseViewModel, PokemonDetailViewModelProtocol {
  
  private let pokemonUseCase: PokemonUseCaseProtocol
  private let pokemon: Pokemon
  
  let loadDetailTrigger = PublishSubject<Void>()
  let closeTrigger = PublishSubject<Void>()
  
  let pokemonDetail = BehaviorRelay<Pokemon?>(value: nil)
  
  var onClose: (() -> Void)?
  
  init(pokemon: Pokemon, pokemonUseCase: PokemonUseCaseProtocol) {
    self.pokemon = pokemon
    self.pokemonUseCase = pokemonUseCase
    super.init()
    setupBindings()
    setupInitialData()
  }
  
  override func initialize() {
    super.initialize()
    loadPokemonDetail()
  }
  
  private func setupBindings() {
    loadDetailTrigger
      .subscribe(onNext: { [weak self] in
        self?.loadPokemonDetail()
      })
      .disposed(by: disposeBag)
    
    closeTrigger
      .subscribe(onNext: { [weak self] in
        self?.close()
      })
      .disposed(by: disposeBag)
  }
  
  private func setupInitialData() {
    pokemonDetail.accept(pokemon)
  }
  
  func loadPokemonDetail() {
    guard !isLoading.value else { return }
    
    setLoading(true)
    
    pokemonUseCase.fetchPokemonDetail(id: pokemon.id)
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] detailedPokemon in
          self?.pokemonDetail.accept(detailedPokemon)
          self?.setLoading(false)
        },
        onError: { [weak self] error in
          self?.setLoading(false)
          self?.handleDetailError(error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func close() {
    onClose?()
  }
  
  private func handleDetailError(_ error: Error) {
    let errorMessage = error.localizedDescription
    
    let alert = UIAlertController(
      title: "Error Loading Details",
      message: "Could not load detailed information for \(pokemon.name). Showing basic info only.\n\n\(errorMessage)",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
      self?.loadPokemonDetail()
    })
    
    handleError(error)
  }
}
