//
//  BubbleView.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import SwiftUI
import SwiftDown
import Down
import AppKit
import Highlighter

struct BubbleView: View {
  
  let message: Message

  var body: some View {
    HStack(alignment: .bottom) {
      
      if !message.incoming {
        Spacer(minLength: 60)
      }

      VStack(alignment: .leading) {
        ForEach(message.content, id: \.id) { content in
          Text(content.attributedString)
            .padding(content.padding)
            .background(content.backgroundColor)
            .cornerRadius(content.padding)
        }
      }
      .textSelection(.enabled)
      .padding([.top, .bottom], 4)
      .padding([.leading, .trailing], 6)
      .foregroundColor(Color.white)
      .background(message.incoming ? Color(hue: 0, saturation: 0, brightness: 0.18) : .blue)
      .cornerRadius(16)
    }
  }
  
}

extension Message.Content {
  var attributedString: AttributedString {
    switch self {
    case let .text(attributedString, _), let .code(attributedString, _):
      return attributedString
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .text:
      return .clear
      
    case .code:
      return .black
    }
  }
  
  var padding: CGFloat {
    switch self {
    case .text:
      return 5
      
    case .code:
      return 10
    }
  }
}

