//
//  BaseViewController.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 05/08/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

protocol BaseViewControllerProtocol: AnyObject {
  func setupUI()
  func setupBindings()
  func showLoading()
  func hideLoading()
  func showError(_ error: Error)
}

class BaseViewController<ViewModel: BaseViewModelProtocol>: UIViewController, BaseViewControllerProtocol {
  
  var viewModel: ViewModel!
  let disposeBag = DisposeBag()
  private var loadingHUD: MBProgressHUD?
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented - Use programmatic initialization")
  }
  
  deinit {}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBaseUI()
    setupUI()
    setupBaseBindings()
    setupBindings()
    
    
    viewModel?.initialize()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    viewModel?.activate()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel?.deactivate()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  private func setupBaseUI() {
    view.backgroundColor = UIColor(hex: Constants.Colors.background).withAlphaComponent(0.05)
    
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }
  }
  
  private func setupBaseBindings() {
    guard let viewModel = viewModel else { return }
    
    viewModel.isLoading
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isLoading in
        if isLoading {
          self?.showLoading()
        } else {
          self?.hideLoading()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.error
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] error in
        self?.showError(error)
      })
      .disposed(by: disposeBag)
  }
  
  func setupUI() {}
  
  func setupBindings() {}
  
  func showLoading() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      if self.loadingHUD == nil {
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD?.mode = .indeterminate
        self.loadingHUD?.bezelView.color = UIColor(hex: Constants.Colors.primary)
        self.loadingHUD?.contentColor = UIColor(hex: Constants.Colors.primary)
      }
    }
  }
  
  func hideLoading() {
    DispatchQueue.main.async { [weak self] in
      if let hud = self?.loadingHUD {
        hud.hide(animated: true)
        self?.loadingHUD = nil
      }
    }
  }
  
  func showError(_ error: Error) {
    DispatchQueue.main.async { [weak self] in
      let alert = UIAlertController(
        title: "Error",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
      
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self?.present(alert, animated: true)
    }
  }
}
