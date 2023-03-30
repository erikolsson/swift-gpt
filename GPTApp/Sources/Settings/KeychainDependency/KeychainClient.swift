//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation
import Dependencies
import KeychainAccess

public struct KeychainClient {
  public var getString: (_ key: String) throws -> String?
  public var setString: (_ key: String, _ value: String) throws -> Void
}

extension KeychainClient {
  static let live: KeychainClient = {
    let keychain = KeychainAccess.Keychain()
    return KeychainClient { key in
      try keychain.get(key)
    } setString: { key, value in
      try keychain.set(value, key: key)
    }
  }()
  
  static let test: KeychainClient = {
    let keychain = KeychainAccess.Keychain()
    fatalError()
  }()
}


extension DependencyValues {

  var keychainClient: KeychainClient {
    get { self[KeychainClientKey.self] }
    set { self[KeychainClientKey.self] = newValue }
  }

  enum KeychainClientKey: DependencyKey {
    public static let liveValue = KeychainClient.live
    public static let testValue = KeychainClient.test
  }

}
