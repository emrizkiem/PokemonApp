//
//  PokemonHeaderView.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PokemonHeaderView: UIView {
  
  private lazy var backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: Constants.Colors.primary)
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: Constants.Fonts.title, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  
  var title: String? {
    get { return titleLabel.text }
    set { titleLabel.text = newValue }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  convenience init(title: String) {
    self.init(frame: .zero)
    self.title = title
  }
  
  private func setupUI() {
    addSubview(backgroundView)
    backgroundView.addSubview(titleLabel)
    
    backgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-20)
    }
    
    snp.makeConstraints { make in
      make.height.equalTo(Constants.UI.headerHeight)
    }
  }
}
