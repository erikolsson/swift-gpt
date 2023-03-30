import ComposableArchitecture
import Chat
import Settings
import Common

public struct GPTAppReducer: ReducerProtocol {
  
  public struct State: Equatable {
    var settings = SettingsReducer.State()
    var chats = IdentifiedArrayOf<ChatReducer.State>()
    var model: String = "" {
      didSet {
        for id in chats.ids {
          chats[id: id]?.model = model
        }
        print(model )
      }
    }

    @BindingState var filter: String = ""
    @BindingState var selectedChatID: ChatReducer.State.ID
    public init() {
      selectedChatID = .init()
    }
    
    mutating func sortChats() {
      self.chats.sort()
    }

  }
  
  public enum Action: BindableAction, Equatable {
    case viewDidLoad
    case didLoadMessages([Common.Message])
    case binding(BindingAction<State>)
    case addChat
    case selectChat(ChatReducer.State.ID)
    case settings(SettingsReducer.Action)
    case chat(id: ChatReducer.State.ID, action: ChatReducer.Action)
  }
  
  @Dependency(\.databaseClient) var databaseClient
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .viewDidLoad:
        return .merge(
          .task{ .settings(.load) },
          .run { send in
            do {
              let messages = try await databaseClient.load()
              await send(.didLoadMessages(messages))
            } catch let err {
              print(err)
            }
          }
        )
        
      case let .didLoadMessages(messages):
        for message in messages {
          if state.chats[id: message.parentID] == nil {
            let chat = ChatReducer.State(id: message.parentID)
            state.chats.updateOrAppend(chat)
          }
          
          let mapped = Chat.Message(id: message.id, text: message.text, incoming: message.incoming, createdAt: message.createdAt)
          state.chats[id: message.parentID]?.appendMessage(message: mapped)
        }
        state.sortChats()
        state.selectedChatID = state.chats.first?.id ?? state.selectedChatID
        return .none
        
      case .addChat:
        let chat = ChatReducer.State.init()
        state.chats.insert(chat, at: 0)
        state.selectedChatID = chat.id
        return .none
        
      case let.selectChat(id):
        state.selectedChatID = id
        return .none
        
      case .chat(id: _, action: .didReceiveResponse), .chat(id: _, action: .submit):
        state.sortChats()
        return .none

      case .settings(.didSetModel):
        state.model = state.settings.selectedModel
        return .none

      case .chat, .binding, .settings:
        return .none
      }
    }
    .forEach(\.chats, action: /Action.chat(id:action:)) {
      ChatReducer()
    }
    
    Scope(state: \.settings, action: /Action.settings) {
      SettingsReducer()
    }
  }
  public init() {}
}
