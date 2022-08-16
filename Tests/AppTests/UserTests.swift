//
//  UserTests.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    let userName = "Alice"
    let userUsername = "alicea"
    let userPassword = "password"
    let usersURI = "/api/users/"
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(name: userName, username: userUsername, on: app.db)
        _ = try User.create(on: app.db)
        
        try app.test(.GET, "api/users", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User.Public].self)
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, userName)
            XCTAssertEqual(users[0].username, userUsername)
            XCTAssertEqual(users[0].id, user.id)
        })
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: userName, username: userUsername, password: userPassword)
        
        try app.test(.POST, usersURI, loggedInRequest: true, beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { response in
            let receivedUser = try response.content.decode(User.Public.self)
            
            XCTAssertEqual(receivedUser.name, user.name)
            XCTAssertEqual(receivedUser.username, user.username)
            XCTAssertNotNil(receivedUser.id)
            
            try app.test(.GET, usersURI, afterResponse: { secondResponse in
                let users = try secondResponse.content.decode([User.Public].self)
                
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users[1].name, userName)
                XCTAssertEqual(users[1].username, userUsername)
                XCTAssertEqual(users[1].id, receivedUser.id)
            })
        })
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: app.db)
        
        let acronymShort = "OMG"
        let acronumLong = "Oh My God"
        
        let acronym = try Acronym.create(short: acronymShort, long: acronumLong, user: user, on: app.db)
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Lound", user: user, on: app.db)
        
        try app.test(.GET, "\(usersURI)\(user.id!)/acronyms", afterResponse: { response in
            let acronums = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronums.count, 2)
            XCTAssertEqual(acronums[0].short, acronym.short)
            XCTAssertEqual(acronums[0].long, acronym.long)
            XCTAssertEqual(acronums[0].id, acronym.id)
        })
    }
}
