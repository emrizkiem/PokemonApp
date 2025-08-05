//
//  SplashViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol SplashViewControllerDelegate: AnyObject {
  func splashDidComplete()
}

final class SplashViewController: BaseViewController<SplashViewModel> {
  
  weak var delegate: SplashViewControllerDelegate?
  
  private let logoContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: Constants.Colors.accent)
    view.layer.cornerRadius = 50
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let logoLabel: UILabel = {
    let label = UILabel()
    label.text = "⚡"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 48)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = Constants.App.name
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
    label.textColor = UIColor(hex: Constants.Colors.primary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Catch 'em all!"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.textColor = UIColor(hex: Constants.Colors.textSecondary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    startUIAnimation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func setupUI() {
    view.addSubview(logoContainer)
    logoContainer.addSubview(logoLabel)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    
    setupConstraints()
  }
  
  override func setupBindings() {
    viewModel.animationCompleted
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.finishUIAnimation()
      })
      .disposed(by: disposeBag)
  }
  
  private func startUIAnimation() {
    logoContainer.alpha = 0
    titleLabel.alpha = 0
    subtitleLabel.alpha = 0
    
    logoContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    
    UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut) {
      self.logoContainer.alpha = 1
      self.logoContainer.transform = .identity
    }
    
    UIView.animate(withDuration: 0.6, delay: 0.8) {
      self.titleLabel.alpha = 1
    }
    
    UIView.animate(withDuration: 0.6, delay: 1.0) {
      self.subtitleLabel.alpha = 1
    }
  }
  
  private func finishUIAnimation() {
    UIView.animate(withDuration: Constants.UI.animationDuration) {
      self.view.alpha = 0
    } completion: { _ in
      self.delegate?.splashDidComplete()
    }
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
      logoContainer.widthAnchor.constraint(equalToConstant: 100),
      logoContainer.heightAnchor.constraint(equalToConstant: 100),
      
      logoLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
      logoLabel.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
      
      titleLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: Constants.Spacing.md),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Spacing.xl),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.xl),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Spacing.sm),
      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Spacing.xl),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.xl)
    ])
  }
}

