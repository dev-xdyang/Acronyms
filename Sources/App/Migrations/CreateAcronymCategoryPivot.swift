//
//  CreateAcronymCategoryPivot.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent
import Vapor

struct CreateAcronymCategoryPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(AcronymCategoryPivot.schema)
            .id()
            .field(AcronymCategoryPivot.Key.acronym.fieldKey, .uuid, .required, .references(Acronym.schema, Acronym.Key.id.fieldKey, onDelete: .cascade))
            .field(AcronymCategoryPivot.Key.category.fieldKey, .uuid, .required, .references(Category.schema, Category.Key.id.fieldKey, onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(AcronymCategoryPivot.schema)
            .delete()
    }
}
