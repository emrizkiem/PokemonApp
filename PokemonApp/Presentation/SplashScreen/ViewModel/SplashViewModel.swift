//
//  SplashViewModel.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol SplashViewModelProtocol: BaseViewModelProtocol {
  var animationCompleted: PublishRelay<Void> { get }
  
  func startSplashSequence()
  func completeSplashSequence()
}

final class SplashViewModel: BaseViewModel, SplashViewModelProtocol {
  
  let animationCompleted = PublishRelay<Void>()
  private var splashTimer: Timer?
  
  override func initialize() {
    super.initialize()
    
    startSplashSequence()
  }
  
  override func activate() {
    super.activate()
  }
  
  override func deactivate() {
    super.deactivate()
    
    stopSplashTimer()
  }
  
  override func cleanup() {
    super.cleanup()
    stopSplashTimer()
  }
  
  func startSplashSequence() {
    setLoading(false)
    
    splashTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
      self?.completeSplashSequence()
    }
  }
  
  func completeSplashSequence() {
    setLoading(false)
    stopSplashTimer()
    animationCompleted.accept(())
  }
  
  private func stopSplashTimer() {
    splashTimer?.invalidate()
    splashTimer = nil
  }
}
