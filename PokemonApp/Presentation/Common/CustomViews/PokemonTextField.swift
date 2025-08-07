//
//  PokemonTextField.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 07/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PokemonTextField: UIView {
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: Constants.Fonts.body, weight: .medium)
    label.textColor = UIColor(hex: Constants.Colors.textSecondary)
    return label
  }()
  
  lazy var textField: UITextField = {
    let textField = UITextField()
    textField.font = UIFont.systemFont(ofSize: Constants.Fonts.body)
    textField.borderStyle = .none
    textField.backgroundColor = UIColor(hex: Constants.Colors.textFieldBackground)
    textField.textColor = UIColor(hex: Constants.Colors.textFieldText)
    textField.layer.cornerRadius = Constants.UI.cornerRadius
    textField.layer.borderWidth = Constants.UI.borderWidth
    textField.layer.borderColor = UIColor(hex: Constants.Colors.textFieldBorder).cgColor
    
    textField.attributedPlaceholder = NSAttributedString(
      string: "",
      attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: Constants.Colors.placeholder)]
    )
    
    let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
    textField.leftView = leftPadding
    textField.leftViewMode = .always
    
    let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
    textField.rightView = rightPadding
    textField.rightViewMode = .always
    
    return textField
  }()
  
  private let disposeBag = DisposeBag()
  
  var text: String {
    get { return textField.text ?? "" }
    set { textField.text = newValue }
  }
  
  var placeholder: String? {
    get { return textField.placeholder }
    set {
      textField.attributedPlaceholder = NSAttributedString(
        string: newValue ?? "",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: Constants.Colors.placeholder)]
      )
    }
  }
  
  var title: String? {
    get { return titleLabel.text }
    set {
      titleLabel.text = newValue
      titleLabel.isHidden = newValue == nil
    }
  }
  
  var keyboardType: UIKeyboardType {
    get { return textField.keyboardType }
    set { textField.keyboardType = newValue }
  }
  
  var returnKeyType: UIReturnKeyType {
    get { return textField.returnKeyType }
    set { textField.returnKeyType = newValue }
  }
  
  var isSecureTextEntry: Bool {
    get { return textField.isSecureTextEntry }
    set { textField.isSecureTextEntry = newValue }
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    get { return textField.autocapitalizationType }
    set { textField.autocapitalizationType = newValue }
  }
  
  var autocorrectionType: UITextAutocorrectionType {
    get { return textField.autocorrectionType }
    set { textField.autocorrectionType = newValue }
  }
  
  var rx_text: ControlProperty<String?> {
    return textField.rx.text
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  convenience init(title: String, placeholder: String) {
    self.init(frame: .zero)
    self.title = title
    self.placeholder = placeholder
  }
  
  private func setupUI() {
    addSubview(titleLabel)
    addSubview(textField)
    
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Spacing.sm)
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(Constants.UI.textFieldHeight)
    }
  }
  
  func setValidationState(_ isValid: Bool?) {
    guard let isValid = isValid else {
      // Reset to default state
      textField.layer.borderColor = UIColor(hex: Constants.Colors.textFieldBorder).cgColor
      return
    }
    
    let borderColor = isValid ? UIColor(hex: Constants.Colors.success) : UIColor(hex: Constants.Colors.error)
    
    UIView.animate(withDuration: Constants.Animation.duration) { [weak self] in
      self?.textField.layer.borderColor = borderColor.cgColor
    }
  }
  
  func setError(_ hasError: Bool) {
    setValidationState(hasError ? false : nil)
  }
  
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }
  
  @discardableResult
  override func resignFirstResponder() -> Bool {
    return textField.resignFirstResponder()
  }
}
