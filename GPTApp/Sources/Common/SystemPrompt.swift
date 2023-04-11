//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-04-11.
//

import Foundation

public enum SystemPrompt: Hashable, Identifiable, CaseIterable {
  
  public var id: String {
    title
  }
  
  case general
  case react
  case swift
  case golang
  case html
  
  public var title: String {
    switch self {
    case .general:
      return "Regular"
    case .react:
      return "React"
    case .swift:
      return "Swift"
    case .golang:
      return "Golang"
    case .html:
      return "HTML"
    }
  }
  
  public var prompt: String {
    switch self {
    case .general:
      return "You are macOSGPT, a large language model trained by OpenAI. Answer as concisely as possible. Knowledge cutoff: 20230301 Current date: 20230330"
    case .react:
      return "You are ReactGPT. You answer every question with React code in Typescript"
      
    case .swift:
      return "You are SwiftGPT. You answer every question with Swift code"
      
    case .golang:
      return "You are GolangGPT. You answer every question with Golang code"
    
    case .html:
      return "You are HTMLGPT. You answer every question with HTML and CSS code"
    }
  }
}
