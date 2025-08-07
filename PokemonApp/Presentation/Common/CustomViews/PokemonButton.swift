//
//  PokemonButton.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PokemonButton: UIButton {
  
  enum Style {
    case primary
    case secondary
    
    var backgroundColor: UIColor {
      switch self {
      case .primary:
        return UIColor(hex: Constants.Colors.primary)
      case .secondary:
        return UIColor.clear
      }
    }
    
    var titleColor: UIColor {
      switch self {
      case .primary:
        return .white
      case .secondary:
        return UIColor(hex: Constants.Colors.primary)
      }
    }
    
    var borderColor: UIColor? {
      switch self {
      case .primary:
        return nil
      case .secondary:
        return UIColor(hex: Constants.Colors.primary)
      }
    }
    
    var borderWidth: CGFloat {
      switch self {
      case .primary:
        return 0
      case .secondary:
        return 2
      }
    }
  }
  
  private var style: Style = .primary
  private let disposeBag = DisposeBag()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupButton()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupButton()
  }
  
  convenience init(title: String, style: Style = .primary) {
    self.init(frame: .zero)
    setTitle(title, for: .normal)
    apply(style: style)
  }
  
  private func setupButton() {
    titleLabel?.font = UIFont.systemFont(ofSize: Constants.Fonts.body, weight: .semibold)
    layer.cornerRadius = Constants.UI.cornerRadius
    
    addTarget(self, action: #selector(touchDown), for: .touchDown)
    addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    
    snp.makeConstraints { make in
      make.height.equalTo(Constants.UI.buttonHeight)
    }
  }
  
  func apply(style: Style) {
    self.style = style
    
    backgroundColor = style.backgroundColor
    setTitleColor(style.titleColor, for: .normal)
    setTitleColor(style.titleColor.withAlphaComponent(0.6), for: .disabled)
    
    if let borderColor = style.borderColor {
      layer.borderColor = borderColor.cgColor
      layer.borderWidth = style.borderWidth
    } else {
      layer.borderColor = UIColor.clear.cgColor
      layer.borderWidth = 0
    }
    
    updateAppearanceForState()
  }
  
  override var isEnabled: Bool {
    didSet {
      updateAppearanceForState()
    }
  }
  
  private func updateAppearanceForState() {
    UIView.animate(withDuration: Constants.Animation.duration) { [weak self] in
      guard let self = self else { return }
      
      if self.isEnabled {
        self.alpha = 1.0
        self.backgroundColor = self.style.backgroundColor
      } else {
        self.alpha = 0.6
        if self.style == .primary {
          self.backgroundColor = UIColor.systemGray3
        }
      }
    }
  }
  
  @objc private func touchDown() {
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self?.alpha = 0.8
      }
    )
  }
  
  @objc private func touchUp() {
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        self?.transform = CGAffineTransform.identity
        self?.alpha = self?.isEnabled == true ? 1.0 : 0.6
      }
    )
  }
}
