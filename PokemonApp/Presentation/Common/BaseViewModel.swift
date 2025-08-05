//
//  BaseViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol BaseViewModelProtocol {
  var isLoading: BehaviorRelay<Bool> { get }
  var error: PublishRelay<Error> { get }
  var disposeBag: DisposeBag { get }
  
  func initialize()
  func activate()
  func deactivate()
  func cleanup()
}

class BaseViewModel: BaseViewModelProtocol {
  
  let isLoading = BehaviorRelay<Bool>(value: false)
  let error = PublishRelay<Error>()
  let disposeBag = DisposeBag()
  
  init() {
    setupBindings()
  }
  
  deinit {}
  
  func initialize() {}
  
  func activate() {}
  
  func deactivate() {}
  
  func cleanup() {}
  
  private func setupBindings() {}
  
  func setLoading(_ loading: Bool) {
    isLoading.accept(loading)
  }
  
  func handleError(_ error: Error) {
    setLoading(false)
    self.error.accept(error)
  }
}
