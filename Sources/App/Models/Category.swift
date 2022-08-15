//
//  Category.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent
import Vapor

extension Category {
    struct Key {
        static let id = "id"
        static let name = "name"
    }
}

final class Category: Model, Content {
    static var schema = "categories"
    
    @ID
    var id: UUID?
    
    @Field(Key.name)
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
