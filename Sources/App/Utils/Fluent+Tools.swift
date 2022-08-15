//
//  Fluent+Tools.swift
//  
//
//  Created by 阳小东 on 2022/8/10.
//

import Fluent

extension String {
    var fieldKey: FieldKey {
        FieldKey(stringLiteral: self)
    }
}

extension FieldProperty {
    convenience init(_ key: String) {
        self.init(key: key.fieldKey)
    }
}

extension OptionalFieldProperty {
    convenience init(_ key: String) {
        self.init(key: key.fieldKey)
    }
}

extension ParentProperty {
    convenience init(_ key: String) {
        self.init(key: key.fieldKey)
    }
}

extension OptionalParentProperty {
    convenience init(_ key: String) {
        self.init(key: key.fieldKey)
    }
}
