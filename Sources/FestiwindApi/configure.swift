import NIOSSL
import Fluent
import FluentMySQLDriver
import FluentSQLiteDriver
import Vapor
import Gatekeeper
import JWT

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    if app.environment == .testing {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "root",
            password: Environment.get("DATABASE_PASSWORD") ?? "",
            database: Environment.get("DATABASE_NAME") ?? "festiwind_db"
        ), as: .mysql)
    }
    
    //------------------- Services ----------------------
    app.asyncCommands.use(SeedCommand(), as: "seed")

    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "stringmaisadressmailaussiazertyavecselpoivresaladtomatogno"))

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType],
        cacheExpiration: 800
        )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    
    //------------------- Middlewares ----------------------
    
    //CORS
    app.middleware.use(corsMiddleware, at: .beginning) //le .begining assure que le cors soit tjs au debut de la chaine des middleware meme si un autre dev en implemente un au dessus de celui ci.
    
    if app.environment != .testing {
        app.caches.use(.memory)
        app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
        app.middleware.use(GatekeeperMiddleware())
    }
    
 
    //------------------- Migrations ----------------------
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateWorkshop())
    app.migrations.add(CreateReservation())
    
    


    // register routes
    try routes(app)
}
