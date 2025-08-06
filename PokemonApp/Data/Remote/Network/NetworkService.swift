//
//  NetworkService.swift
//  PokemonApp
//
//  Created by M. Rizki Maulana on 06/08/25.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkServiceProtocol {
  func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) -> Observable<T>
}

final class NetworkService: NetworkServiceProtocol {
  
  private let session: Session
  private let reachabilityManager: NetworkReachabilityManager?
  
  init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = Constants.API.timeoutInterval
    configuration.timeoutIntervalForResource = Constants.API.timeoutInterval
    
    session = Session(configuration: configuration)
    reachabilityManager = NetworkReachabilityManager()
    
    startReachabilityMonitoring()
    
    print("🌐 NetworkManager initialized")
  }
  
  deinit {
    reachabilityManager?.stopListening()
    print("💀 NetworkManager deallocated")
  }
  
  func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) -> Observable<T> {
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onError(NetworkError.unknown)
        return Disposables.create()
      }
      
      guard self.isConnectedToInternet() else {
        observer.onError(NetworkError.noInternetConnection)
        return Disposables.create()
      }
      
      guard let urlRequest = self.buildURLRequest(from: endpoint) else {
        observer.onError(NetworkError.invalidURL)
        return Disposables.create()
      }
      
      print("🌐 Making request to: \(urlRequest.url?.absoluteString ?? "unknown")")
      
      let request = self.session.request(urlRequest)
        .validate()
        .responseData { response in
          switch response.result {
          case .success(let data):
            do {
              let decodedObject = try JSONDecoder().decode(T.self, from: data)
              print("✅ Request successful: \(endpoint.path)")
              observer.onNext(decodedObject)
              observer.onCompleted()
            } catch {
              print("❌ Decoding error: \(error)")
              observer.onError(NetworkError.decodingError(error))
            }
          case .failure(let error):
            print("❌ Network error: \(error)")
            observer.onError(self.mapAlamofireError(error))
          }
        }
      
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  private func buildURLRequest(from endpoint: APIEndpoint) -> URLRequest? {
    var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path)
    
    if let queryItems = endpoint.queryItems {
      urlComponents?.queryItems = queryItems
    }
    
    guard let url = urlComponents?.url else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    
    endpoint.headers?.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if let parameters = endpoint.parameters,
       endpoint.method != .GET {
      do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
      } catch {
        print("❌ Failed to serialize parameters: \(error)")
        return nil
      }
    }
    
    return request
  }
  
  private func mapAlamofireError(_ error: AFError) -> NetworkError {
    switch error {
    case .responseValidationFailed(let reason):
      switch reason {
      case .unacceptableStatusCode(let code):
        switch code {
        case 401:
          return .unauthorized
        case 403:
          return .forbidden
        case 404:
          return .notFound
        case 500...599:
          return .serverError(code)
        default:
          return .serverError(code)
        }
      default:
        return .networkError(error)
      }
    case .sessionTaskFailed(let sessionError):
      if (sessionError as NSError).code == NSURLErrorTimedOut {
        return .timeout
      } else if (sessionError as NSError).code == NSURLErrorNotConnectedToInternet {
        return .noInternetConnection
      } else {
        return .networkError(error)
      }
    default:
      return .networkError(error)
    }
  }
  
  private func isConnectedToInternet() -> Bool {
    return reachabilityManager?.isReachable ?? true
  }
  
  private func startReachabilityMonitoring() {
    reachabilityManager?.startListening { status in
      switch status {
      case .reachable:
        print("🌐 Internet connection available")
      case .notReachable:
        print("❌ No internet connection")
      case .unknown:
        print("⚠️ Internet connection status unknown")
      }
    }
  }
}
