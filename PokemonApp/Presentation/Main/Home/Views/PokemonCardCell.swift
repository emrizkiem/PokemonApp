//
//  PokemonCardCell.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import SnapKit

final class PokemonCardCell: UICollectionViewCell {
  
  static let identifier = "PokemonCardCell"
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 16
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.3).cgColor
    return view
  }()
  
  private lazy var emojiImageView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 30
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var emojiLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  
  private lazy var typeLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textColor = UIColor.white.withAlphaComponent(0.7)
    label.textAlignment = .center
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
    containerView.addSubview(emojiImageView)
    emojiImageView.addSubview(emojiLabel)
    containerView.addSubview(nameLabel)
    containerView.addSubview(typeLabel)
    
    setupConstraints()
    setupShadow()
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    emojiImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(60)
    }
    
    emojiLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(emojiImageView.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(8)
    }
    
    typeLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(8)
      make.bottom.lessThanOrEqualToSuperview().offset(-16)
    }
  }
  
  private func setupShadow() {
    layer.shadowColor = UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.3).cgColor
    layer.shadowOffset = CGSize(width: 0, height: 4)
    layer.shadowRadius = 8
    layer.shadowOpacity = 0
  }
  
  func configure(with data: PokemonCardData) {
    nameLabel.text = data.name
    typeLabel.text = data.type
    emojiLabel.text = data.emoji
    
    setupGradientBackground(colors: data.colors)
    
    containerView.backgroundColor = UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.1)
  }
  
  private func setupGradientBackground(colors: [String]) {
    emojiImageView.layer.sublayers?.removeAll { $0 is CAGradientLayer }
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    gradientLayer.cornerRadius = 30
    
    gradientLayer.colors = colors.compactMap { UIColor(hex: $0).cgColor }
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    
    emojiImageView.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    emojiImageView.layer.sublayers?.removeAll { $0 is CAGradientLayer }
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
      self.layer.shadowOpacity = pressed ? 0.3 : 0
    }
  }
}
