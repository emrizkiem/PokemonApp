//
//  LoginViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol LoginViewControllerDelegate: AnyObject {
  func loginDidSucceed(user: User)
  func loginRequestRegister()
}

final class LoginViewController: BaseViewController<LoginViewModel> {
  
  weak var delegate: LoginViewControllerDelegate?
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.keyboardDismissMode = .onDrag
    return scrollView
  }()
  
  private lazy var contentView = UIView()
  
  private lazy var headerView = PokemonHeaderView(title: Constants.Strings.Auth.loginScreen)
  
  private lazy var titleView = PokemonTitleView(
    title: Constants.Strings.Auth.loginTitle,
    subtitle: Constants.Strings.Auth.loginSubtitle
  )
  
  private lazy var emailTextField: PokemonTextField = {
    let textField = PokemonTextField(
      title: Constants.Strings.Auth.email,
      placeholder: Constants.Strings.Auth.emailPlaceholder
    )
    textField.keyboardType = .emailAddress
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    return textField
  }()
  
  private lazy var passwordTextField: PokemonTextField = {
    let textField = PokemonTextField(
      title: Constants.Strings.Auth.password,
      placeholder: Constants.Strings.Auth.passwordPlaceholder
    )
    textField.isSecureTextEntry = true
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    return textField
  }()
  
  private lazy var loginButton = PokemonButton(
    title: Constants.Strings.Auth.loginButton,
    style: .primary
  )
  
  private lazy var createAccountButton = PokemonButton(
    title: Constants.Strings.Auth.createAccountButton,
    style: .secondary
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupKeyboardHandling()
  }
  
  override func setupUI() {
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(titleView)
    contentView.addSubview(emailTextField)
    contentView.addSubview(passwordTextField)
    contentView.addSubview(loginButton)
    contentView.addSubview(createAccountButton)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
      make.height.greaterThanOrEqualTo(view).priority(.low)
    }
    
    titleView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Constants.Spacing.huge)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    emailTextField.snp.makeConstraints { make in
      make.top.equalTo(titleView.snp.bottom).offset(Constants.Spacing.huge + Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    passwordTextField.snp.makeConstraints { make in
      make.top.equalTo(emailTextField.snp.bottom).offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    loginButton.snp.makeConstraints { make in
      make.top.equalTo(passwordTextField.snp.bottom).offset(Constants.Spacing.huge)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    createAccountButton.snp.makeConstraints { make in
      make.top.equalTo(loginButton.snp.bottom).offset(Constants.Spacing.md)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
      make.bottom.equalToSuperview().offset(-Constants.Spacing.huge)
    }
  }
  
  override func setupBindings() {
    guard let viewModel = viewModel else { return }
    
    emailTextField.rx_text.orEmpty
      .bind(to: viewModel.email)
      .disposed(by: disposeBag)
    
    passwordTextField.rx_text.orEmpty
      .bind(to: viewModel.password)
      .disposed(by: disposeBag)
    
    loginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
        viewModel.login()
      })
      .disposed(by: disposeBag)
    
    createAccountButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate?.loginRequestRegister()
      })
      .disposed(by: disposeBag)
    
    viewModel.loginSuccess
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] user in
        self?.delegate?.loginDidSucceed(user: user)
      })
      .disposed(by: disposeBag)
    
    viewModel.loginError
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] errorMessage in
        self?.showErrorAlert(errorMessage)
      })
      .disposed(by: disposeBag)
  }

  private func setupKeyboardHandling() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    
    let keyboardHeight = keyboardFrame.height
    scrollView.contentInset.bottom = keyboardHeight
    scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset.bottom = 0
    scrollView.verticalScrollIndicatorInsets.bottom = 0
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  private func showErrorAlert(_ message: String) {
    let alert = UIAlertController(
      title: Constants.Strings.Errors.loginFailed,
      message: message,
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
