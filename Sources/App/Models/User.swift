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
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
    }
}
