//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import SwiftUI
import ComposableArchitecture
import Chat
import Settings

public struct GPTAppView: View {
  let store: StoreOf<GPTAppReducer>
  
  public init(store: StoreOf<GPTAppReducer>) {
    self.store = store
  }
  
  @State var modalViewVisible = false
  
  public var body: some View {
    NavigationSplitView {
      WithViewStore(store, observe: {$0} ) { viewStore in
          List(selection: viewStore.binding(\.$selectedChatID)) {
            ForEach(viewStore.chats.map(\.id), id: \.self) { id in
              IfLetStore(store.scope(state: \.chats[id: id], action: { GPTAppReducer.Action.chat(id: id, action: $0) })) { store in
                WithViewStore(store) { viewStore in
                  Text(viewStore.title)
                }
              }
            }
          }
          .onAppear {
            viewStore.send(.viewDidLoad)
          }
          .toolbar {
            
            ToolbarItemGroup(placement: .automatic) {
              Spacer()
              Button {
                modalViewVisible.toggle()
              } label: {
                Image(systemName: "gear")
              }
              Button {
                viewStore.send(.addChat)
              } label: {
                Image(systemName: "square.and.pencil")
              }
            }
          }
        }
    } detail: {
      WithViewStore(store, observe: \.selectedChatID) { viewStore in
        IfLetStore(store.scope(state: \.chats[id: viewStore.state],
                               action: { GPTAppReducer.Action.chat(id: viewStore.state, action: $0)})) { store in
          ChatView(store: store)
        }
      }
      .toolbar {
        
        ToolbarItemGroup(placement: .automatic) {
        
          SettingsToolbarView(store: store.scope(state: \.settings,
                                                 action: GPTAppReducer.Action.settings))
        }

      }
    }
    .navigationSplitViewStyle(.prominentDetail)
    .sheet(isPresented: $modalViewVisible) {
      SettingsView(store: store.scope(state: \.settings, action: GPTAppReducer.Action.settings))
    }
    
  }
  
}
