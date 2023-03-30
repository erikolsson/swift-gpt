//
//  SettingsReducer.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import ComposableArchitecture
import API

public struct SettingsReducer: ReducerProtocol {
  
  @Dependency(\.keychainClient) var keychainClient

  public struct State: Equatable {
    @BindingState var key: String = ""
    @BindingState public var selectedModel = ""
    var models: [OpenAIModel] = []
    
    public init() {}
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case loadModels
    case didLoadModels(TaskResult<[OpenAIModel]>)
    case load
    case save
    case didSetModel
  }
  
  @Dependency(\.api) var api
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .loadModels:
        let key = state.key
        return .run { send in
          do {
            let models = try await api.models(key)
            await send(.didLoadModels(.success(models)))
          } catch let err {
            await send(.didLoadModels(.failure(err)))
          }
        }
        
      case let .didLoadModels(.success(models)):
        state.models = models.filter({$0.id.hasPrefix("gpt")}).sorted(by: {$0.id.localizedCompare($1.id) == .orderedAscending})
        if state.selectedModel.isEmpty {
          state.selectedModel = state.models.first?.id ?? ""
        }
        return .task { .didSetModel }
        
      case let .didLoadModels(.failure(err)):
        print(err)
        return .none

      case .save:
        do {
          try keychainClient.setString("key", state.key)
        } catch let err {
          print(err)
        }
        return .task { .loadModels }
        
      case .load:
        do {
          state.key = try keychainClient.getString("key") ?? ""
        } catch let err {
          print(err)
        }
        if !state.key.isEmpty {
          return .task { .loadModels }
        }
        return .none

      case .binding(\.$selectedModel):
        return .task { .didSetModel }

      case .binding, .didSetModel:
        return .none
      }
    }
  }
  
  public init() {}
}

extension SettingsReducer.State {
  var needsAPIKey: Bool {
    return key.isEmpty
  }
}
