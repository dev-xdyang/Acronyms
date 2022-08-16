//
//  Models+Testable.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

@testable import App
import Fluent
import Vapor

extension User {
    static func create(name: String = "Luke", username: String = "lukes", password: String = "password", on database: Database) throws -> User {
        let user = try User(name: name, username: username, password: Bcrypt.hash(password))
        try user.save(on: database).wait()
        return user
    }
}

extension Acronym {
    static func create(short: String = "TIL", long: String = "Today I Learned", user: User? = nil, on database: Database) throws -> Acronym {
        var acronymUser = user
        
        if acronymUser == nil {
            acronymUser = try User.create(on: database)
        }
        
        let acronym = Acronym(short: short, long: long, userID: acronymUser!.id!)
        try acronym.save(on: database).wait()
        return acronym
    }
}
