//
//  PokemonDetailViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 10/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

final class PokemonDetailViewController: BaseViewController<PokemonDetailViewModel> {
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    button.tintColor = .white
    button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    button.layer.cornerRadius = 20
    button.layer.masksToBounds = true
    return button
  }()
  
  private lazy var pokemonImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var pokemonNumberLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .white.withAlphaComponent(0.8)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var pokemonNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  
  private lazy var typesStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private lazy var statsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    return view
  }()
  
  private lazy var statsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .fill
    return stackView
  }()
  
  private lazy var physicalStatsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 20
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private var currentPokemon: Pokemon?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCloseButton()
  }
  
  override func setupUI() {
    view.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    view.addSubview(closeButton)
    
    contentView.addSubview(pokemonImageView)
    contentView.addSubview(pokemonNumberLabel)
    contentView.addSubview(pokemonNameLabel)
    contentView.addSubview(typesStackView)
    contentView.addSubview(statsContainerView)
    
    statsContainerView.addSubview(statsStackView)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.width.height.equalTo(40)
    }
    
    pokemonImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(80)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(200)
    }
    
    pokemonNumberLabel.snp.makeConstraints { make in
      make.top.equalTo(pokemonImageView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    pokemonNameLabel.snp.makeConstraints { make in
      make.top.equalTo(pokemonNumberLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    typesStackView.snp.makeConstraints { make in
      make.top.equalTo(pokemonNameLabel.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
      make.height.equalTo(40)
    }
    
    statsContainerView.snp.makeConstraints { make in
      make.top.equalTo(typesStackView.snp.bottom).offset(40)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.greaterThanOrEqualTo(400)
    }
    
    statsStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(30)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().offset(-30)
    }
  }
  
  private func setupCloseButton() {
    closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
  }
  
  @objc private func closeButtonTapped() {
    viewModel.closeTrigger.onNext(())
  }
  
  override func setupBindings() {
    // Pokemon detail binding
    viewModel.pokemonDetail
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] pokemon in
        self?.updateUI(with: pokemon)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateUI(with pokemon: Pokemon?) {
    guard let pokemon = pokemon else { return }
    
    currentPokemon = pokemon
    
    pokemonNumberLabel.text = String(format: "#%03d", pokemon.id)
    pokemonNameLabel.text = pokemon.displayName
    
    if let primaryType = pokemon.types.first {
      let backgroundColor = UIColor(hex: PokemonTypeColor.color(for: primaryType))
      view.backgroundColor = backgroundColor
    }
    
    loadPokemonImage(pokemon: pokemon)
    updateTypesDisplay(types: pokemon.types)
    updateStatsDisplay(pokemon: pokemon)
  }
  
  private func loadPokemonImage(pokemon: Pokemon) {
    let imageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
    
    guard let url = URL(string: imageURL) else {
      showErrorImage()
      return
    }
    
    pokemonImageView.kf.setImage(
      with: url,
      placeholder: nil,
      options: [
        .transition(.fade(0.3)),
        .cacheOriginalImage
      ]
    ) { [weak self] result in
      switch result {
      case .success(_):
        break
      case .failure(_):
        self?.showErrorImage()
      }
    }
  }
  
  private func showErrorImage() {
    pokemonImageView.image = UIImage(systemName: "questionmark.circle")?
      .withTintColor(.white.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
  }
  
  private func updateTypesDisplay(types: [String]) {
    typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for type in types {
      let typeView = createTypeView(type: type)
      typesStackView.addArrangedSubview(typeView)
    }
  }
  
  private func createTypeView(type: String) -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    containerView.layer.cornerRadius = 16
    
    let label = UILabel()
    label.text = type.capitalized
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    
    containerView.addSubview(label)
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16)
      make.top.bottom.equalToSuperview().inset(8)
    }
    
    containerView.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(80)
    }
    
    return containerView
  }
  
  private func updateStatsDisplay(pokemon: Pokemon) {
    statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    let titleLabel = UILabel()
    titleLabel.text = "Stats"
    titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
    titleLabel.textColor = UIColor(hex: Constants.Colors.primary)
    statsStackView.addArrangedSubview(titleLabel)
    
    // Add physical stats
    setupPhysicalStats(pokemon: pokemon)
    statsStackView.addArrangedSubview(physicalStatsStackView)
    
    if !pokemon.stats.isEmpty {
      setupBattleStats(stats: pokemon.stats)
    } else {
      let loadingLabel = UILabel()
      loadingLabel.text = "Loading detailed stats..."
      loadingLabel.font = .systemFont(ofSize: 16)
      loadingLabel.textColor = .gray
      loadingLabel.textAlignment = .center
      statsStackView.addArrangedSubview(loadingLabel)
    }
  }
  
  private func setupPhysicalStats(pokemon: Pokemon) {
    physicalStatsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    let heightView = createPhysicalStatView(
      title: "Height",
      value: String(format: "%.1f m", pokemon.heightInMeters),
      icon: "ruler"
    )
    physicalStatsStackView.addArrangedSubview(heightView)
    
    let weightView = createPhysicalStatView(
      title: "Weight",
      value: String(format: "%.1f kg", pokemon.weightInKg),
      icon: "scalemass"
    )
    physicalStatsStackView.addArrangedSubview(weightView)
  }
  
  private func createPhysicalStatView(title: String, value: String, icon: String) -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = UIColor(hex: Constants.Colors.background).withAlphaComponent(0.1)
    containerView.layer.cornerRadius = 12
    
    let iconImageView = UIImageView()
    iconImageView.image = UIImage(systemName: icon)
    iconImageView.tintColor = UIColor(hex: Constants.Colors.primary)
    iconImageView.contentMode = .scaleAspectFit
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
    titleLabel.textColor = .gray
    titleLabel.textAlignment = .center
    
    let valueLabel = UILabel()
    valueLabel.text = value
    valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
    valueLabel.textColor = UIColor(hex: Constants.Colors.primary)
    valueLabel.textAlignment = .center
    
    containerView.addSubview(iconImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(valueLabel)
    
    iconImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(iconImageView.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(8)
    }
    
    valueLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(8)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    return containerView
  }
  
  private func setupBattleStats(stats: [PokemonStatData]) {
    for stat in stats {
      let statView = createBattleStatView(stat: stat)
      statsStackView.addArrangedSubview(statView)
    }
  }
  
  private func createBattleStatView(stat: PokemonStatData) -> UIView {
    let containerView = UIView()
    
    let nameLabel = UILabel()
    nameLabel.text = stat.displayName
    nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
    nameLabel.textColor = UIColor(hex: Constants.Colors.primary)
    
    let valueLabel = UILabel()
    valueLabel.text = "\(stat.baseStat)"
    valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
    valueLabel.textColor = UIColor(hex: Constants.Colors.primary)
    
    let progressView = UIProgressView(progressViewStyle: .default)
    progressView.progress = Float(stat.baseStat) / 255.0 // Max stat is usually 255
    progressView.progressTintColor = UIColor(hex: Constants.Colors.primary)
    progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
    
    containerView.addSubview(nameLabel)
    containerView.addSubview(valueLabel)
    containerView.addSubview(progressView)
    
    nameLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
      make.width.equalTo(120)
    }
    
    valueLabel.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview()
      make.width.equalTo(50)
    }
    
    progressView.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(8)
    }
    
    return containerView
  }
}
