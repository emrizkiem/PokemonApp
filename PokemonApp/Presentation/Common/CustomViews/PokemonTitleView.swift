//
//  PokemonTitleView.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PokemonTitleView: UIView {
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: Constants.Fonts.largeTitle, weight: .bold)
    label.textColor = UIColor(hex: Constants.Colors.primary)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: Constants.Fonts.subtitle, weight: .medium)
    label.textColor = UIColor(hex: Constants.Colors.textSecondary)
    label.textAlignment = .center
    return label
  }()
  
  var title: String? {
    get { return titleLabel.text }
    set { titleLabel.text = newValue }
  }
  
  var subtitle: String? {
    get { return subtitleLabel.text }
    set { subtitleLabel.text = newValue }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  convenience init(title: String, subtitle: String) {
    self.init(frame: .zero)
    self.title = title
    self.subtitle = subtitle
  }
  
  private func setupUI() {
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Spacing.sm)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}
