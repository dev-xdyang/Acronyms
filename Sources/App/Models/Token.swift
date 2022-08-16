//
//  Token.swift
//  
//
//  Created by 阳小东 on 2022/8/16.
//

import Vapor
import Fluent

extension Token {
    struct Key {
        static let token = "token"
        static let userID = "userID"
    }
}

final class Token: Model, Content {
    static var schema = "tokens"
    
    @ID
    var id: UUID?
    
    @Field(Key.token)
    var token: String
    
    @Parent(Key.userID)
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.token = value
        self.$user.id = userID
    }
}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userID: user.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    typealias User = App.User
    
    static var valueKey = \Token.$token
    static var userKey = \Token.$user
    
    var isValid: Bool { true }
}
