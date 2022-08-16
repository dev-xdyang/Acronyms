//
//  UserController.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Vapor
import Fluent
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userGroup = routes.grouped("api", "users")
        
        userGroup.get(use: getAllHandler(_:))
        userGroup.get(":id", use: getHandler(_:))
        userGroup.get(":id", "acronyms", use: getAcronymsHandler)
        
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = userGroup.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler(_:))
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokeAuthGroup = userGroup.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokeAuthGroup.post(use: createHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [User.Public] {
        try await User.query(on: req.db).all().map(\.publicView)
    }
    
    func getHandler(_ req: Request) async throws -> User.Public {
        let id: UUID? = req.parameters.get("id")
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return user.publicView
    }
    
    func createHandler(_ req: Request) async throws -> User.Public {
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        try await user.save(on: req.db)
        return user.publicView
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        let id: UUID? = req.parameters.get("id")
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$acronyms.get(on: req.db)
    }
    
    func loginHandler(_ req: Request) async throws -> Token {
        let user = try req.auth.require(User.self)
        let token = try Token.generate(for: user)
        try await token.save(on: req.db)
        return token
    }
}
