//
//  Models.swift
//  TestFluentKitOptionalChildCrash
//
//  Created by Erik Hatfield on 1/29/25.
//

import Foundation
import FluentSQLiteDriver

public enum Schemas: String {
    case parentModel = "parentModel"
    case optionalChildModel = "optionalChildModel"
}

@preconcurrency
final public class ParentModel: Model, @unchecked Sendable {
    static public let schema = Schemas.parentModel.rawValue
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "characterId")
    public var characterId: String
    
    @OptionalChild(for: \.$parentModel)
    public var optionalChild: OptionalChildModel?
    
    public init() { }
    
    public init(characterID: String) {
        self.characterId = characterID
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(ParentModel.schema)
                .id()
                .field("characterId", .string)
                .unique(on: "characterId")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(ParentModel.schema)
                .delete()
        }
    }
}

final public class OptionalChildModel: Model, @unchecked Sendable {
    static public let schema = Schemas.optionalChildModel.rawValue
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "optionalChild_id")
    public var parentModel: ParentModel
    
    @Field(key: "value")
    public var value: String
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        value: String
    ) {
        self.id = id
        self.value = value
    }
        
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(OptionalChildModel.schema)
                .id()
                .field(
                    "optionalChild_id",
                    .uuid,
                    .required,
                    .references(Schemas.parentModel.rawValue, "id")
                )
                .field("value", .string, .required)
                .create()
        }
            
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(OptionalChildModel.schema)
                .delete()
        }
    }
    
}
