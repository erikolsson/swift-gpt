//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case patch = "PATCH"
  case put = "PUT"
}

struct HTTPHeader {
  let field: String
  let value: String
}

struct URLRequestBuilder {

  let baseURL: URL
  let path: String
  let method: HTTPMethod
  let headers: [HTTPHeader]
  let queryItems: [URLQueryItem]
  let body: Data?

  init(baseURL: URL,
       path: String = "",
       method: HTTPMethod = .get,
       headers: [HTTPHeader] = [],
       parameters: [URLQueryItem] = [],
       body: Data? = nil) {
    self.baseURL = baseURL
    self.path = path
    self.method = method
    self.headers = headers
    self.queryItems = parameters
    self.body = body
  }

  func get(path: String) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: .get,
                             headers: headers,
                             parameters: queryItems,
                             body: body)
  }

  func post(path: String) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: .post,
                             headers: headers,
                             parameters: queryItems,
                             body: body)
  }

  func patch(path: String) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: .patch,
                             headers: headers,
                             parameters: queryItems,
                             body: body)
  }

  func put(path: String) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: .put,
                             headers: headers,
                             parameters: queryItems,
                             body: body)
  }

  func with(headers: [HTTPHeader]) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: method,
                             headers: self.headers + headers,
                             parameters: queryItems,
                             body: body)
  }

  func with(queryItems: [URLQueryItem]) -> URLRequestBuilder {
    return URLRequestBuilder(baseURL: baseURL,
                             path: path,
                             method: method,
                             headers: headers,
                             parameters: self.queryItems + queryItems,
                             body: body)
  }

  func with<Body: Encodable>(body: Body) -> URLRequestBuilder {
    do {
      return URLRequestBuilder(baseURL: baseURL,
                               path: path,
                               method: method,
                               headers: headers,
                               parameters: queryItems,
                               body: try JSONEncoder().encode(body))
    } catch {
      preconditionFailure("Could not encode params: \(error)")
    }
  }

  func request() -> URLRequest {
    var components = URLComponents()
    components.scheme = baseURL.scheme
    components.host = baseURL.host
    components.path = baseURL.path
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    components.port = baseURL.port
    guard let url = components.url?.appendingPathComponent(path) else {
      preconditionFailure("Bad URL!")
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    headers.forEach({request.addValue($0.value, forHTTPHeaderField: $0.field)})

    return request
  }

}

extension URLRequestBuilder {
  static var openAI: URLRequestBuilder {
    let url = URL(string: "https://api.openai.com/")!
    return URLRequestBuilder(baseURL: url)
  }
}
