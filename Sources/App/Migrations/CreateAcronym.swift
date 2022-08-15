//
//  CreateAcronym.swift
//  
//
//  Created by 阳小东 on 2022/8/10.
//

import Fluent

struct CreateAcronym: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Acronym.schema)
            .id()
            .field(Acronym.Key.short.fieldKey, .string, .required)
            .field(Acronym.Key.long.fieldKey, .string, .required)
            .field(Acronym.Key.userID.fieldKey, .uuid, .required, .references(User.schema, User.Key.id.fieldKey))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Acronym.schema)
            .delete()
    }
}

