//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation

public struct OpenAICompletionsResponse: Equatable, Decodable {
  
  public struct Choice: Equatable, Decodable {
    public let message: Message
  }
  
  public struct Message: Equatable, Decodable {
    public let role: String
    public let content: String
  }
  
  public let id: String
  public let usage: [String: Int]
  public let choices: [Choice]
}
