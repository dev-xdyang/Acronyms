//
//  UserController.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userGroup = routes.grouped("api", "users")
        
        userGroup.get(use: getAllHandler(_:))
        userGroup.get(":id", use: getHandler(_:))
        userGroup.get(":id", "acronyms", use: getAcronymsHandler)
        
        userGroup.post(use: createHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> User {
        let id: UUID? = req.parameters.get("id")
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }
    
    func createHandler(_ req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        let id: UUID? = req.parameters.get("id")
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$acronyms.get(on: req.db)
    }
}
