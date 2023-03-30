//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation
import API
import Down

public struct Message: Hashable, Identifiable {
  
  enum Content: Hashable {
    case text(AttributedString, Int)
    case code(AttributedString, Int)
    
    var id: Int {
      switch self {
      case let .code(_, index), let .text(_, index):
        return index
      }
    }
  }
  
  public let id: String
  public let text: String
  public let incoming: Bool
  public let createdAt: Date
  let content: [Content]
  
  public init(id: String = UUID().uuidString, text: String, incoming: Bool, createdAt: Date) {
    self.id = id
    self.text = text
    self.incoming = incoming
    self.createdAt = createdAt
    self.content = contentFromString(string: text)
  }
  
  var asOpenAIMessage: OpenAICompletionsRequest.Message {
    return .init(role: incoming ? "assistant" : "user", content: text)
  }
  
}

private func contentFromString(string: String) -> [Message.Content] {
  
  return string.components(separatedBy: "```").enumerated().map({ index, element -> Message.Content in
    
    if index.isMultiple(of: 2) {
      let down = Down(markdownString: element)
      let attributedString: AttributedString
      do {
        let nsAttributedString = try down.toAttributedString(styler: MarkdownStyler.shared)
        attributedString = AttributedString(nsAttributedString)
      } catch let err {
        print(err)
        attributedString = AttributedString(stringLiteral: element)
      }
      
      return .text(attributedString, index)
    }

    let down = Down(markdownString: "```\n" + element + "\n```")
    let attributedString: AttributedString
    do {
      let nsAttributedString = try down.toAttributedString(styler: MarkdownStyler.shared)
      attributedString = AttributedString(nsAttributedString)
    } catch let err {
      print(err)
      attributedString = AttributedString(stringLiteral: element)
    }
    
    return .code(attributedString, index)
  })

  
}
