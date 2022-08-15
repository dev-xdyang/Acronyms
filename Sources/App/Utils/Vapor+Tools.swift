//
//  File.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import Vapor

extension HTTPResponseStatus {
    static func badRequestForMissQuery(key: String) -> Self {
        .custom(code: Self.badRequest.code, reasonPhrase: "Value missed for query parameter key '\(key)' ")
    }
}
