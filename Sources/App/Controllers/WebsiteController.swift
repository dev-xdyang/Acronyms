//
//  WebsiteController.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Vapor
import Fluent

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler(_:))
        routes.get("users", ":userID", use: userHandler(_:))
        routes.get("users", use: allUserHandler(_:))
        routes.get("categories", use: allCategoriesHandler(_:))
        routes.get("categories", ":categoryID", use: categoryHandler(_:))
        
        routes.get("acronyms", "create", use: createAcronymHandler(_:))
        routes.post("acronyms", "create", use: createAcronymPostHandler(_:))
        routes.get("acronyms", ":acronymID", "edit", use: editAcronymHandler(_:))
        routes.post("acronyms", ":acronymID", "edit", use: editAcronymPostHandler(_:))
        routes.post("acronyms", ":acronymID", "delete", use: deleteAcronymHandler(_:))
    }

    func indexHandler(_ req: Request) async throws -> View {
        let acronyms = try await Acronym.query(on: req.db).all()
        let context = IndexContext(title: "Home page", acronyms: acronyms)
        return try await req.view.render("index", context)
    }
    
    func acronymHandler(_ req: Request) async throws -> View {
        let acronymID: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        let user = try await acronym.$user.get(on: req.db)
        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
        return try await req.view.render("acronym", context)
    }
    
    func userHandler(_ req: Request) async throws -> View {
        let userID: UUID? = req.parameters.get("userID")
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        let acronyms = try await user.$acronyms.query(on: req.db).all()
        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
        return try await req.view.render("user", context)
    }
    
    func allUserHandler(_ req: Request) async throws -> View {
        let users = try await User.query(on: req.db).all()
        let conext = AllUsersContext(title: "All users", users: users)
        return try await req.view.render("allUsers", conext)
    }
    
    func allCategoriesHandler(_ req: Request) async throws -> View {
        let categories = try await Category.query(on: req.db).all()
        let context = AllCategoriesContext(categories: categories)
        return try await req.view.render("allCategories", context)
    }
    
    func categoryHandler(_ req: Request) async throws -> View {
        let categoryID: UUID? = req.parameters.get("categoryID")
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        let acronyms = try await category.$acronyms.query(on: req.db).all()
        let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
        return try await req.view.render("category", context)
    }
    
    
    func createAcronymHandler(_ req: Request) async throws -> View {
        let useres = try await User.query(on: req.db).all()
        let context = CreateAcronymContext(users: useres)
        return try await req.view.render("createAcronym", context)
    }
    
    func createAcronymPostHandler(_ req: Request) async throws -> Response {
        let acronymDTO = try req.content.decode(CreateAcronymDTO.self)
        let acronym = Acronym(short: acronymDTO.short, long: acronymDTO.long, userID: acronymDTO.userID)
        try await acronym.save(on: req.db)
        guard let id = acronym.id else {
            throw Abort(.internalServerError)
        }
        return req.redirect(to: "/acronyms/\(id)")
    }
    
    func editAcronymHandler(_ req: Request) async throws -> View {
        let acronymID: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        let users = try await User.query(on: req.db).all()
        let context = EditAcronymContext(acronym: acronym, users: users)
        return try await req.view.render("createAcronym", context)
    }
    
    func editAcronymPostHandler(_ req: Request) async throws -> Response {
        let acronymID: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let acronymDTO = try req.content.decode(CreateAcronymDTO.self)
        acronym.short = acronymDTO.short
        acronym.long = acronymDTO.long
        acronym.$user.id = acronymDTO.userID
        
        guard let id = acronym.id else {
            throw Abort(.internalServerError)
        }
        
        try await acronym.save(on: req.db)
        return req.redirect(to: "/acronyms/\(id)")
    }
    
    func deleteAcronymHandler(_ req: Request) async throws -> Response {
        let acronymID: UUID? = req.parameters.get("acronymID")
        guard let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await acronym.delete(on: req.db)
        return req.redirect(to: "/")
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    let title: String = "All Categories"
    let categories: [Category]
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: [Acronym]
}

struct CreateAcronymContext: Encodable {
    let title = "Create An Acronym"
    let users: [User]
}

struct EditAcronymContext: Encodable {
    let title = "Edit Acronym"
    let acronym: Acronym
    let users: [User]
    let editing = true
}
