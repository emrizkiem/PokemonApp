//
//  RegisterViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol RegisterViewControllerDelegate: AnyObject {
  func registerDidSucceed(user: User)
  func registerRequestLogin()
}

final class RegisterViewController: BaseViewController<RegisterViewModel> {
  
  weak var delegate: RegisterViewControllerDelegate?
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.keyboardDismissMode = .onDrag
    return scrollView
  }()
  
  private lazy var contentView = UIView()
  
  private lazy var headerView = PokemonHeaderView(title: Constants.Strings.Auth.registerScreen)
  
  private lazy var titleView = PokemonTitleView(
    title: Constants.Strings.Auth.registerTitle,
    subtitle: Constants.Strings.Auth.registerSubtitle
  )
  
  private lazy var fullNameTextField: PokemonTextField = {
    let textField = PokemonTextField(
      title: Constants.Strings.Auth.fullName,
      placeholder: Constants.Strings.Auth.fullNamePlaceholder
    )
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .no
    return textField
  }()
  
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
      placeholder: "Password (min 6 characters)"
    )
    textField.isSecureTextEntry = true
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    return textField
  }()
  
  private lazy var registerButton = PokemonButton(
    title: Constants.Strings.Auth.registerButton,
    style: .primary
  )
  
  private lazy var backToLoginButton = PokemonButton(
    title: Constants.Strings.Auth.backToLoginButton,
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
    contentView.addSubview(fullNameTextField)
    contentView.addSubview(emailTextField)
    contentView.addSubview(passwordTextField)
    contentView.addSubview(registerButton)
    contentView.addSubview(backToLoginButton)
    
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
    
    fullNameTextField.snp.makeConstraints { make in
      make.top.equalTo(titleView.snp.bottom).offset(Constants.Spacing.huge)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    emailTextField.snp.makeConstraints { make in
      make.top.equalTo(fullNameTextField.snp.bottom).offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    passwordTextField.snp.makeConstraints { make in
      make.top.equalTo(emailTextField.snp.bottom).offset(Constants.Spacing.lg)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    registerButton.snp.makeConstraints { make in
      make.top.equalTo(passwordTextField.snp.bottom).offset(Constants.Spacing.xl)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
    }
    
    backToLoginButton.snp.makeConstraints { make in
      make.top.equalTo(registerButton.snp.bottom).offset(Constants.Spacing.md)
      make.leading.trailing.equalToSuperview().inset(Constants.Spacing.xl)
      make.bottom.equalToSuperview().offset(-Constants.Spacing.huge)
    }
  }
  
  override func setupBindings() {
    guard let viewModel = viewModel else { return }
    
    // Input bindings
    fullNameTextField.rx_text.orEmpty
      .bind(to: viewModel.fullName)
      .disposed(by: disposeBag)
    
    emailTextField.rx_text.orEmpty
      .bind(to: viewModel.email)
      .disposed(by: disposeBag)
    
    passwordTextField.rx_text.orEmpty
      .bind(to: viewModel.password)
      .disposed(by: disposeBag)
    
    // Validation visual feedback
    setupValidationFeedback(viewModel)
    
    // Button actions
    registerButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
        viewModel.register()
      })
      .disposed(by: disposeBag)
    
    backToLoginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        // ✅ Direct delegate call - same pattern as SplashViewController
        self?.delegate?.registerRequestLogin()
      })
      .disposed(by: disposeBag)
    
    // Output bindings
    viewModel.registerSuccess
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] user in
        print("✅ Registration successful for: \(user.fullName)")
        self?.handleRegistrationSuccess(user)
      })
      .disposed(by: disposeBag)
    
    viewModel.registerError
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] errorMessage in
        self?.showErrorAlert(errorMessage)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupValidationFeedback(_ viewModel: RegisterViewModel) {
    // Password validation visual feedback
    viewModel.password
      .map { password -> Bool? in
        if password.isEmpty {
          return nil  // Default state
        } else if password.count < 6 {
          return false  // Invalid
        } else {
          return true   // Valid
        }
      }
      .subscribe(onNext: { [weak self] isValid in
        self?.passwordTextField.setValidationState(isValid)
      })
      .disposed(by: disposeBag)
    
    // Full name validation
    viewModel.fullName
      .map { fullName -> Bool? in
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
          return nil
        } else if trimmedName.count < 2 {
          return false
        } else {
          return true
        }
      }
      .subscribe(onNext: { [weak self] isValid in
        self?.fullNameTextField.setValidationState(isValid)
      })
      .disposed(by: disposeBag)
    
    // Email validation (basic)
    viewModel.email
      .map { email -> Bool? in
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
          return nil
        } else {
          return trimmedEmail.contains("@") && trimmedEmail.contains(".")
        }
      }
      .subscribe(onNext: { [weak self] isValid in
        self?.emailTextField.setValidationState(isValid)
      })
      .disposed(by: disposeBag)
  }
  
  private func handleRegistrationSuccess(_ user: User) {
    let alert = UIAlertController(
      title: Constants.Strings.Success.registrationSuccessful,
      message: "\(Constants.Strings.Success.welcomeMessage), \(user.fullName)!",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
      self?.delegate?.registerRequestLogin()
    })
    
    present(alert, animated: true)
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
      title: Constants.Strings.Errors.registrationFailed,
      message: message,
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    print("🎯 RegisterViewController deinitialized")
  }
}
