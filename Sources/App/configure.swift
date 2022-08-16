import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    //: file serve
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    
    //: db
    // db config
    let databaseName: String
    let databasePort: Int
    
    if app.environment == .testing {
        databaseName = "vapor-test"
        databasePort = 5433
    } else if app.environment == .development {
        databaseName = "vapor_database"
        databasePort = 5434
    } else {
        databaseName = "vapor_database"
        databasePort = 5432
    }
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)

    // migration
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAdminUser())
    
//    try app.autoRevert().wait() // uncomment to revert all database data
    try app.autoMigrate().wait()
    
    
    //: template engine
    app.views.use(.leaf)
    
    
    //: route
    // register routes
    try routes(app)
}
