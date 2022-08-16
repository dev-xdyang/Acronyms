//
//  CreateToken.swift
//  
//
//  Created by 阳小东 on 2022/8/16.
//

import Fluent

struct CreateToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Token.schema)
            .id()
            .field(Token.Key.token.fieldKey, .string, .required)
            .field(Token.Key.userID.fieldKey, .uuid, .required, .references(User.schema, User.Key.id.fieldKey))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema)
            .delete()
    }
}
