//
//  AcronymCategoryPivot.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Fluent
import Foundation

extension AcronymCategoryPivot {
    struct Key {
        static let acronym = "acronym"
        static let category = "category"
    }
}

final class AcronymCategoryPivot: Model {
    static var schema = "acronym-category-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(Key.acronym)
    var acronym: Acronym
    
    @Parent(Key.category)
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
