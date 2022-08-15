//
//  CategoriesController.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesGroup = routes.grouped("api", "categories")
        
        categoriesGroup.get(use: getAll(_:))
        categoriesGroup.get(":categoryID", use: get(_:))
        categoriesGroup.post(use: create(_:))
        
        categoriesGroup.get(":categoryID", "acronyms", use: getAcronyms(_:))
    }
    
    func getAll(_ req: Request) async throws -> [Category] {
        try await Category.query(on: req.db).all()
    }
    
    func get(_ req: Request) async throws -> Category {
        let id: UUID? = req.parameters.get("categoryID")
        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return category
    }
    
    func create(_ req: Request) async throws -> Category {
        let category = try req.content.decode(Category.self)
        try await category.save(on: req.db)
        return category
    }
}

extension CategoriesController {
    func getAcronyms(_ req: Request) async throws -> [Acronym] {
        let id: UUID? = req.parameters.get("categoryID")
        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await category.$acronyms.query(on: req.db).all()
    }
}
