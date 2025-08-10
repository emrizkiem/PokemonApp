//
//  PokemonCardCell.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import SnapKit
import Kingfisher

final class PokemonCardCell: UICollectionViewCell {
  
  static let identifier = "PokemonCardCell"
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 12
    view.backgroundColor = UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.1)
    view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowRadius = 5
    view.layer.shadowOpacity = 1.0
    return view
  }()
  
  private lazy var pokemonNumberLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12, weight: .medium)
    label.textColor = UIColor(hex: Constants.Colors.textSecondary)
    label.textAlignment = .right
    return label
  }()
  
  private lazy var pokemonImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.hidesWhenStopped = true
    indicator.color = .gray
    return indicator
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = UIColor(hex: Constants.Colors.textSecondary)
    label.textAlignment = .center
    label.numberOfLines = 1
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    contentView.addSubview(containerView)
    containerView.addSubview(pokemonNumberLabel)
    containerView.addSubview(pokemonImageView)
    containerView.addSubview(loadingIndicator)
    containerView.addSubview(nameLabel)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(160)
    }
    
    pokemonNumberLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.trailing.equalToSuperview().offset(-10)
    }
    
    pokemonImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(80)
    }
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalTo(pokemonImageView)
    }
    
    nameLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-8)
      make.leading.trailing.equalToSuperview().inset(8)
    }
  }
  
  func configure(with pokemon: Pokemon) {
    pokemonNumberLabel.text = String(format: "#%03d", pokemon.id)
    nameLabel.text = pokemon.name.capitalized
    loadPokemonImage(with: pokemon.id)
  }
  
  private func loadPokemonImage(with pokemonId: Int) {
    let imageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId).png"
    
    guard let url = URL(string: imageURL) else {
      showErrorImage()
      return
    }
    
    // Show loading indicator
    loadingIndicator.startAnimating()
    pokemonImageView.image = nil
    
    // Load image with Kingfisher
    pokemonImageView.kf.setImage(
      with: url,
      placeholder: nil,
      options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage
      ]
    ) { [weak self] result in
      DispatchQueue.main.async {
        self?.loadingIndicator.stopAnimating()
        
        switch result {
        case .success(_):
          break
        case .failure(_):
          self?.showErrorImage()
        }
      }
    }
  }
  
  private func showErrorImage() {
    pokemonImageView.image = UIImage(systemName: "image")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    pokemonImageView.kf.cancelDownloadTask()
    pokemonImageView.image = nil
    loadingIndicator.stopAnimating()
    pokemonNumberLabel.text = nil
    nameLabel.text = nil
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    animatePress(pressed: true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    animatePress(pressed: false)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    animatePress(pressed: false)
  }
  
  private func animatePress(pressed: Bool) {
    UIView.animate(withDuration: 0.1) {
      self.transform = pressed ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
    }
  }
}
