//
//  AcronymsController.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsGroup = routes.grouped("api", "acronyms")
        
        acronymsGroup.get(use: getAllHandler(_:))
        acronymsGroup.get(":acronymID", use: getHandler(_:))
        acronymsGroup.get("first", use: getFirstHandler(_:))
        acronymsGroup.get("sorted", use: getSortedHandler(_:))
        acronymsGroup.get(":acronymID", "user", use: getUserHandler(_:))
        acronymsGroup.get("search", use: searchHandler(_:))
        
        acronymsGroup.get(":acronymID", "categories", use: getCategoriesHandler(_:))
        
        //: Basic auth
        let basicAuthMiddleware = User.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let basicAuthGroup = acronymsGroup.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        basicAuthGroup.post(use: createHandler(_:))
        basicAuthGroup.put(":acronymID", use: updateHandler(_:))
        
        basicAuthGroup.delete(":acronymID", use: deleteHandler(_:))
        
        basicAuthGroup.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler(_:))
        basicAuthGroup.delete(":acronymID", "categories", ":categoryID", use: removeCategories(_:))
    }
    
    func getAllHandler(_ req: Request) async throws -> [Acronym] {
        try await Acronym.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> Acronym {
        guard let result = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return result
    }
    
    func getFirstHandler(_ req: Request) async throws -> Acronym {
        guard let first = try await Acronym.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        return first
    }
    
    func getSortedHandler(_ req: Request) async throws -> [Acronym] {
        try await Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req: Request) async throws -> User.Public {
        let id: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await acronym.$user.get(on: req.db).publicView
    }
    
    func searchHandler(_ req: Request) async throws -> [Acronym] {
        let termKey = "term"
        guard let searchTerm = req.query[String.self, at: termKey] else {
            throw Abort(.badRequestForMissQuery(key: termKey))
        }
        
        return try await Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }
    
    func createHandler(_ req: Request) async throws -> Acronym {
        let acronymDTO = try req.content.decode(CreateAcronymDTO.self)
        let acronym = Acronym(short: acronymDTO.short,
                              long: acronymDTO.long,
                              userID: acronymDTO.userID)
        try await acronym.save(on: req.db)
        return acronym
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym {
        let acronymDTO = try req.content.decode(CreateAcronymDTO.self)
        
        let id: UUID? = req.parameters.get("acronymID")
        guard let old = try await Acronym.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        old.short = acronymDTO.short
        old.long = acronymDTO.long
        old.$user.id = acronymDTO.userID
        
        try await old.save(on: req.db)
        
        return old
    }
    
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        let id: UUID? = req.parameters.get("acronymID")
        guard let value = try await Acronym.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await value.delete(on: req.db)
        return .noContent
    }
}

extension AcronymsController {
    func addCategoriesHandler(_ req: Request) async throws -> HTTPStatus {
        let acronymID: UUID? = req.parameters.get("acronymID")
        let categoryID: UUID? = req.parameters.get("categoryID")
        
        async let acronym = Acronym.find(acronymID, on: req.db)
        async let category = Category.find(categoryID, on: req.db)
        
        guard let acronym = try await acronym,
                let category = try await category else {
            throw Abort(.notFound)
        }
        
        try await acronym.$categories.attach(category, on: req.db)
        return .created
    }
    
    func getCategoriesHandler(_ req: Request) async throws -> [Category] {
        let id: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await acronym.$categories.query(on: req.db).all()
    }
    
    func removeCategories(_ req: Request) async throws -> HTTPStatus {
        let acronymID: UUID? = req.parameters.get("acronymID")
        let categoryID: UUID? = req.parameters.get("categoryID")
        
        async let acronym = Acronym.find(acronymID, on: req.db)
        async let category = Category.find(categoryID, on: req.db)
        
        guard let acronym = try await acronym,
                let category = try await category else {
            throw Abort(.notFound)
        }
        
        try await acronym.$categories.detach(category, on: req.db)
        return .noContent
    }
}

struct CreateAcronymDTO: Content {
    let short: String
    let long: String
    let userID: UUID
}
