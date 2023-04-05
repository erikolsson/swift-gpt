//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import SwiftUI
import ComposableArchitecture
import SwiftDown

public struct ChatView: View {
  
  let store: StoreOf<ChatReducer>
  public init(store: StoreOf<ChatReducer>) {
    self.store = store
  }
  public var body: some View {
    
      VSplitView {
        ScrollViewReader { proxy in
          List {
            WithViewStore(store, observe: \.messages) { viewStore in
              ForEach(viewStore.elements, id: \.self) { msg in
                BubbleView(message: msg).id(msg.id)
              }
              .onChange(of: viewStore.state) { newValue in
                withAnimation {
                  proxy.scrollTo(viewStore.ids.last, anchor: .bottomTrailing)
                }
              }
              .onAppear {
                withAnimation {
                  proxy.scrollTo(viewStore.ids.last, anchor: .bottomTrailing)
                }
              }
            }
          }
        }
        .layoutPriority(0.7)
        
        WithViewStore(store, observe: {$0}) { viewStore in
          HStack {
            SwiftDownEditor(text: viewStore.binding(\.$currentMessageText))
              .insetsSize(14)
              .cornerRadius(14)
              .overlay(RoundedRectangle(cornerRadius: 14).stroke(.primary.opacity(0.2)))
              .overlay(alignment: .bottomTrailing) {
                Button {
                  viewStore.send(.submit)
                } label: {
                  Image(systemName: "paperplane")
                }
                .keyboardShortcut(.init(.return, modifiers: .command))
                .disabled(viewStore.disableSendButton)
                .padding()
              }
          }
          .padding()
        }
        .frame(minHeight: 80)
        .layoutPriority(0.3)
        
      }
  }
  
}
