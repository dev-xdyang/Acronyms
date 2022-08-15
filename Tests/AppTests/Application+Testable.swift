//
//  Application+Testable.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

import App
import XCTVapor

extension Application {
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        
        return app
    }
}
