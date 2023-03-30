//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation

struct OpenAIModelsResponse: Decodable {
  let data: [OpenAIModel]
}

public struct OpenAIModel: Decodable, Equatable {
  public let id: String
  public let object: String
  public let ownedBy: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case object
    case ownedBy = "owned_by"
  }
}



