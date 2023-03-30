//
//  API.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation
import Dependencies
import KeychainAccess

public struct API {
  public var models: @Sendable (String) async throws -> ([OpenAIModel]) = { _ in fatalError() }
  public var chatCompletions: @Sendable (OpenAICompletionsRequest) async throws -> OpenAICompletionsResponse = { _ in fatalError() }
}

extension Keychain {
  static let shared = Keychain()
}

func fetch<T: Decodable>(builder: URLRequestBuilder) async throws -> T {
  let token = try Keychain.shared.get("key") ?? ""
  let (data, _) = try await URLSession.shared.data(for: builder.with(headers: [.init(field: "Authorization", value: "Bearer \(token)")]).request())
  let decoded = try JSONDecoder().decode(T.self, from: data)
  return decoded
}

public extension API {
  static let live: API = {
    var apiClient = API()
    
    apiClient.models = { token in
      let builder = URLRequestBuilder.openAI
        .get(path: "v1/models")
      let response: OpenAIModelsResponse = try await fetch(builder: builder)
      return response.data
    }
    
    apiClient.chatCompletions = { request in
      let builder = URLRequestBuilder.openAI.post(path: "v1/chat/completions")
        .with(headers: [
          HTTPHeader(field: "content-type", value: "application/json")
        ])
        .with(body: request)
      return try await fetch(builder: builder)
    }
    
    return apiClient
  }()
  
  static let test: API = {
    
    return API()
  }()
  
}

public extension DependencyValues {
  var api: API {
    get { self[APIClientKey.self] }
    set { self[APIClientKey.self] = newValue }
  }

  enum APIClientKey: DependencyKey {
    public static let liveValue = API.live
    public static let testValue = API.test
  }

}

