//
//  User.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent
import Vapor

extension User {
    struct Key {
        static let id = "id"
        static let name = "name"
        static let username = "username"
        static let password = "password"
    }
}

final class User: Model, Content {
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(Key.name)
    var name: String
    
    @Field(Key.username)
    var username: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    @Field(Key.password)
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String, password: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
    }
}

extension User {
    final class Public: Codable, Content {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
    
    var publicView: Public {
        Public(id: id, name: name, username: username)
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$username
    static var passwordHashKey  = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
