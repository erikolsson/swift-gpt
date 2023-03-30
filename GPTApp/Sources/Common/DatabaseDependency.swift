//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-30.
//

import Foundation
import GRDB
import Dependencies

public struct Message: Hashable, Codable, Identifiable, FetchableRecord, PersistableRecord {
  public let id: String
  public let parentID: String
  public let text: String
  public let createdAt: Date
  public let incoming: Bool
  
  public init(id: String, parentID: String, text: String, createdAt: Date, incoming: Bool) {
    self.id = id
    self.text = text
    self.createdAt = createdAt
    self.incoming = incoming
    self.parentID = parentID
  }

}

actor MessagesDatabase {
  
  let dbQueue: DatabaseQueue
  init?() {
    let path = URL.documentsDirectory.appendingPathComponent("messages1234.sqlite").absoluteString
    guard let dbQueue = try? DatabaseQueue(path: path) else { return nil }
    self.dbQueue = dbQueue
    
    do {
      try dbQueue.write { database in
        try database.create(table: "message", ifNotExists: true) { definition in
          definition.primaryKey("id", .text).notNull()
          definition.column("parentID", .text).notNull()
          definition.column("text", .text).notNull()
          definition.column("createdAt", .datetime).notNull()
          definition.column("incoming", .boolean).notNull()
        }
      }
    } catch let err {
      print(err)
    }
  }
  
  func messages() throws -> [Message] {
    let messages: [Message] = try dbQueue.read { database in
      try Message.fetchAll(database)
    }
    return messages
  }
  
  func save(message: Message) async throws {
    _ = try await dbQueue.write { [message] db in
      try message.saved(db)
    }
  }

}

public struct DatabaseClient {
  
  public var load: @Sendable () async throws -> [Message] = { fatalError() }
  public var save: (Message) async throws -> Void = { _ in fatalError() }
  
  static let live: DatabaseClient = {
    let database = MessagesDatabase()
    
    var client = DatabaseClient()
    client.load = {
      return try await database?.messages() ?? []
    }
    
    client.save = { message in
      try await database?.save(message: message)
    }
    
    return client
  }()
  
  
  static let test = DatabaseClient()
}

public extension DependencyValues {

  var databaseClient: DatabaseClient {
    get { self[DatabaseClientKey.self] }
    set { self[DatabaseClientKey.self] = newValue }
  }

  enum DatabaseClientKey: DependencyKey {
    public static let liveValue = DatabaseClient.live
    public static let testValue = DatabaseClient.test
  }

}

