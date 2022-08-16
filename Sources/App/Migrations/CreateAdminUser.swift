//
//  CreateAdminUser.swift
//  
//
//  Created by 阳小东 on 2022/8/16.
//

import Vapor
import Fluent

fileprivate struct AdminUser {
    static let name = "Admin"
    static let username = "admin"
    static let password = "password"
}

struct CreateAdminUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        do {
            let passwordHash = try Bcrypt.hash(AdminUser.password)
            let user = User(name: AdminUser.name, username: AdminUser.username, password: passwordHash)
            try await user.save(on: database)
        } catch {
            fatalError("Failed to create admin user: \(error)")
        }
    }
    
    func revert(on database: Database) async throws {
        try await User.query(on: database).filter(\.$username == AdminUser.username).delete()
    }
}
