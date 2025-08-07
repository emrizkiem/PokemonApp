//
//  ProfileViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ProfileViewControllerDelegate: AnyObject {
  func profileDidRequestLogout()
}

final class ProfileViewController: BaseViewController<ProfileViewModel> {
  
  weak var delegate: ProfileViewControllerDelegate?
  var userDefaultsManager: UserDefaultsManagerProtocol?
  var user: User?
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.backgroundColor = UIColor(hex: Constants.Colors.background)
    return scrollView
  }()
  
  private lazy var contentView = UIView()
  
  private lazy var avatarView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 40
    view.clipsToBounds = true
    view.layer.borderWidth = 3
    view.layer.borderColor = UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.3).cgColor
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    gradientLayer.cornerRadius = 40
    gradientLayer.colors = [
      UIColor(hex: Constants.Colors.primary).cgColor,
      UIColor(hex: Constants.Colors.primary).withAlphaComponent(0.7).cgColor
    ]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    
    view.layer.insertSublayer(gradientLayer, at: 0)
    return view
  }()
  
  private lazy var avatarLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 28, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 22, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textColor = UIColor.white.withAlphaComponent(0.6)
    label.textAlignment = .center
    label.text = "Pokemon Master"
    return label
  }()
  
  private lazy var infoStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 0
    stackView.distribution = .fill
    return stackView
  }()
  
  private lazy var logoutButton = PokemonButton(
    title: "Logout",
    style: .primary
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupUserData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.layoutIfNeeded()
  }
  
  override func setupUI() {
    view.backgroundColor = UIColor(hex: Constants.Colors.background)
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(avatarView)
    avatarView.addSubview(avatarLabel)
    contentView.addSubview(nameLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(infoStackView)
    contentView.addSubview(logoutButton)
    
    setupConstraints()
    setupInfoRows()
  }
  
  private func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    avatarView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Spacing.huge)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(80)
    }
    
    avatarLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(avatarView.snp.bottom).offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(Constants.Spacing.xs)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    infoStackView.snp.makeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).offset(Constants.Spacing.huge)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    logoutButton.snp.makeConstraints { make in
      make.top.equalTo(infoStackView.snp.bottom).offset(Constants.Spacing.huge)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
      make.bottom.equalToSuperview().offset(-Constants.Spacing.huge)
    }
  }
  
  private func setupInfoRows() {
    let infoData = [
      ("Full Name", user?.fullName ?? "John Trainer"),
      ("Email", user?.email ?? "john@example.com"),
      ("Joined", user?.joinedDateString ?? "January 2025")
    ]
    
    for (index, (label, value)) in infoData.enumerated() {
      let rowView = createInfoRow(label: label, value: value)
      infoStackView.addArrangedSubview(rowView)
      
      if index < infoData.count - 1 {
        let separator = createSeparator()
        infoStackView.addArrangedSubview(separator)
      }
    }
  }
  
  private func createInfoRow(label: String, value: String) -> UIView {
    let containerView = UIView()
    containerView.snp.makeConstraints { make in
      make.height.equalTo(50)
    }
    
    let labelView = UILabel()
    labelView.text = label
    labelView.font = .systemFont(ofSize: 16, weight: .regular)
    labelView.textColor = UIColor.white.withAlphaComponent(0.7)
    
    let valueView = UILabel()
    valueView.text = value
    valueView.font = .systemFont(ofSize: 16, weight: .medium)
    valueView.textColor = .white
    valueView.textAlignment = .right
    
    containerView.addSubview(labelView)
    containerView.addSubview(valueView)
    
    labelView.snp.makeConstraints { make in
      make.leading.centerY.equalToSuperview()
    }
    
    valueView.snp.makeConstraints { make in
      make.trailing.centerY.equalToSuperview()
      make.leading.greaterThanOrEqualTo(labelView.snp.trailing).offset(Constants.Spacing.md)
    }
    
    return containerView
  }
  
  private func createSeparator() -> UIView {
    let separator = UIView()
    separator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    separator.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    return separator
  }
  
  private func setupUserData() {
    if user == nil {
      if let currentUser = userDefaultsManager?.getCurrentUser() {
        user = currentUser
      }
    }
    
    guard let user = user else {
      print("No user data available for profile")
      return
    }
    
    nameLabel.text = user.fullName
    avatarLabel.text = user.initials
    
    print("Profile setup for: \(user.fullName)")
  }
  
  override func setupBindings() {
    logoutButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate?.profileDidRequestLogout()
      })
      .disposed(by: disposeBag)
  }
}
