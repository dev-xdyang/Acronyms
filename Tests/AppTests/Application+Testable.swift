//
//  Application+Testable.swift
//  
//
//  Created by 阳小东 on 2022/8/11.
//

@testable import App
@testable import XCTVapor

extension Application {
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        
        return app
    }
}

extension XCTApplicationTester {
    func login(user: User) throws -> Token {
        var request = XCTHTTPRequest(method: .POST, url: .init(path: "/api/users/login"), headers: [:], body: ByteBufferAllocator().buffer(capacity: 0))
        request.headers.basicAuthorization = .init(username: user.username, password: "password")
        let response = try performTest(request: request)
        return try response.content.decode(Token.self)
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    @discardableResult
    public func test(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        body: ByteBuffer? = nil,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        beforeRequest: (inout XCTHTTPRequest) async throws -> () = { _ in },
        afterResponse: (XCTHTTPResponse) async throws -> () = { _ in }
    ) async throws -> XCTApplicationTester {
        var request = XCTHTTPRequest(
            method: method,
            url: .init(path: path),
            headers: headers,
            body: body ?? ByteBufferAllocator().buffer(capacity: 0)
        )
        
        // first login and get token
        if loggedInRequest || loggedInUser != nil {
            let userToLogin: User
            
            if let user = loggedInUser {
                userToLogin = user
            } else {
                userToLogin = User(name: AdminUser.name, username: AdminUser.username, password: AdminUser.password)
            }
            
            let token = try login(user: userToLogin)
            request.headers.bearerAuthorization = .init(token: token.token)
        }
        
        try await beforeRequest(&request)
        
        do {
            let response = try self.performTest(request: request)
            try await afterResponse(response)
        } catch {
            XCTFail("\(error)", file: (file), line: line)
            throw error
        }
        return self
    }
    #endif

    @discardableResult
    public func test(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil,
        body: ByteBuffer? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        beforeRequest: (inout XCTHTTPRequest) throws -> () = { _ in },
        afterResponse: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplicationTester {
        var request = XCTHTTPRequest(
            method: method,
            url: .init(path: path),
            headers: headers,
            body: body ?? ByteBufferAllocator().buffer(capacity: 0)
        )
        
        // first login and get token
        if loggedInRequest || loggedInUser != nil {
            let userToLogin: User
            
            if let user = loggedInUser {
                userToLogin = user
            } else {
                userToLogin = User(name: AdminUser.name, username: AdminUser.username, password: AdminUser.password)
            }
            
            let token = try login(user: userToLogin)
            request.headers.bearerAuthorization = .init(token: token.token)
        }
        
        try beforeRequest(&request)
        do {
            let response = try self.performTest(request: request)
            try afterResponse(response)
        } catch {
            XCTFail("\(error)", file: (file), line: line)
            throw error
        }
        return self
    }
}
