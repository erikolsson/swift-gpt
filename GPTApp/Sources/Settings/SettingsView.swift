//
//  SettingsView.swift
//  
//
//  Created by Erik Olsson on 2023-03-29.
//

import SwiftUI
import ComposableArchitecture
import Common

public struct SettingsView: View {
  let store: StoreOf<SettingsReducer>
  public init(store: StoreOf<SettingsReducer>) {
    self.store = store
  }
  
  public var body: some View {
    Form {
      WithViewStore(store, observe: {$0}) { viewStore in
        Section {
            Picker("Model", selection: viewStore.binding(\.$selectedModel)) {
            ForEach(viewStore.models, id: \.id) { model in
              Text(model.id).tag(model.id)
            }
          }
          
          SecureField("API Key", text: viewStore.binding(\.$key))

        } header: {
          Text("OpenAI Settings")
            .bold()
        } footer: {
          Text("Your API key is stored securely in the keychain")
            .foregroundColor(.secondary)
          
          Button("Save") {
            viewStore.send(.save)
          }
        }
        .onAppear {
          viewStore.send(.load)
        }
        Spacer()
      }
    }
    .padding()
    .padding([.leading, .trailing], 60)
    .frame(width: 500, height: 300)
  }
  
}

public struct SettingsToolbarView: View {

  @State var showModal = false
  let store: StoreOf<SettingsReducer>
  public init(store: StoreOf<SettingsReducer>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        
        if viewStore.needsAPIKey {
          Button("Enter your api key") {
            showModal.toggle()
          }
        } else {
          Picker("Model", selection: viewStore.binding(\.$selectedModel)) {
            ForEach(viewStore.models, id: \.id) { model in
              Text(model.id).tag(model.id)
            }
          }
        }

      }
      .sheet(isPresented: $showModal) {
        SettingsView(store: store)
      }
    }
  }
  
}
