//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import Foundation
import ComposableArchitecture
import API
import Common

public struct ChatReducer: ReducerProtocol {
  
  public struct State: Equatable, Identifiable {
    public let id: String
    public var model: String = ""
    let createdAt: Date = Date()
    @BindingState var currentMessageText: String = ""
    @BindingState var systemPrompt = SystemPrompt.general
    var messages = IdentifiedArrayOf<Message>()
    var isLoading = false

    public init(id: String = UUID().uuidString, messages: [Chat.Message] = []) {
      self.id = id
      self.messages.append(contentsOf: messages)
    }
    
    public mutating func appendMessage(message: Message) {
      messages.updateOrAppend(message)
    }

  }

  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case didReceiveResponse(TaskResult<OpenAICompletionsResponse>)
    case submit
  }
  
  @Dependency(\.api) var api
  @Dependency(\.databaseClient) var databaseClient

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .submit:
        
        let newMessage = Message(text: state.currentMessageText, incoming: false, createdAt: Date())
        state.messages.append(newMessage)
        state.currentMessageText = ""
        
        let systemMessage = OpenAICompletionsRequest.Message(role: "system",
                                                             content: state.systemPrompt.prompt)
        let messages = state.messages.map(\.asOpenAIMessage)
        let request = OpenAICompletionsRequest.init(model: state.model, messages: [systemMessage] + messages)
        
        let parentID = state.id
        return .run { [newMessage] send in
          do {
            let response = try await api.chatCompletions(request)
            await send(.didReceiveResponse(.success(response)))
            let databaseMessage = Common.Message(id: newMessage.id, parentID: parentID, text: newMessage.text, createdAt: newMessage.createdAt, incoming: newMessage.incoming)
            try await databaseClient.save(databaseMessage)
          } catch let err {
            await send(.didReceiveResponse(.failure(err)))
          }
        }
        
      case let .didReceiveResponse(.success(response)):
        var databaseMessages: [Common.Message] = []
        for choice in response.choices {
          let text = choice.message.content
          let message = Message(text: text, incoming: true, createdAt: Date())
          state.messages.append(message)

          let databaseMessage = Common.Message(id: message.id, parentID: state.id, text: message.text, createdAt: message.createdAt, incoming: message.incoming)
          databaseMessages.append(databaseMessage)
        }
        
        return .run { [databaseMessages] send in
          do {
            for message in databaseMessages {
              try await databaseClient.save(message)
            }
          } catch let err {
            print(err)
          }
        }
        
      case let .didReceiveResponse(.failure(err)):
        print(err)
        return .none

      case .binding:
        return .none
      }
    }
  }
  
  public init() {}
}

public extension ChatReducer.State {
  
  var title: String {
    return messages.first?.text ?? "New chat"
  }
  
}

extension ChatReducer.State: Comparable {
  
  var sortDate: Date {
    messages.last?.createdAt ?? createdAt
  }
  
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.sortDate > rhs.sortDate
  }

  var disableSendButton: Bool {
    return currentMessageText.isEmpty || model.isEmpty
  }
}
