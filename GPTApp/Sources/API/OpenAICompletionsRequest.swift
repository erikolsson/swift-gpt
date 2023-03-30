//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation

public struct OpenAICompletionsRequest: Encodable {
  
  public let model: String
  public let messages: [Message]

  public init(model: String, messages: [OpenAICompletionsRequest.Message]) {
    self.model = model
    self.messages = messages
  }
    
  public struct Message: Encodable {
    let role: String
    let content: String
    
    public init(role: String, content: String) {
      self.role = role
      self.content = content
    }
  }
}
