//
//  Acronym.swift
//  
//
//  Created by 阳小东 on 2022/8/10.
//

import Vapor
import Fluent

extension Acronym {
    struct Key {
        static let id = "id"
        static let short = "short"
        static let long = "long"
        static let userID = "userID"
    }
}

final class Acronym: Model {
    static let schema = "acronyms"
    
    @ID
    var id: UUID?
    
    @Field(Key.short)
    var short: String
    
    @Field(Key.long)
    var long: String
    
    @Parent(Key.userID)
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

extension Acronym: Content { }
