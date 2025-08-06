# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'PokemonApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PokemonApp
  pod 'Alamofire', '~> 5.0'
  pod 'Kingfisher', '~> 7.0'
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'MBProgressHUD', '~> 1.2'
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'RealmSwift', '~> 10.0'
  pod 'Swinject', '~> 2.8'

  target 'PokemonAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PokemonAppUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
  
end
