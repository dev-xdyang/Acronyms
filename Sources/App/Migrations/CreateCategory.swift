//
//  CreateCategory.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent

struct CreateCategory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Category.schema)
            .id()
            .field(Category.Key.name.fieldKey, .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Category.schema)
            .delete()
    }
}
