//
//  CreateUser.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field(User.Key.name.fieldKey, .string, .required)
            .field(User.Key.username.fieldKey, .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema)
            .delete()
    }
}
