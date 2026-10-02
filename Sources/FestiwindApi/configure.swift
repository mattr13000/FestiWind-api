import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "festiwind_db"
    ), as: .mysql)
    
    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .all, // a remplacer par .custum("origin du front")
        allowedMethods: [.GET, .POST, .PUT, . DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 800
    )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfig)
    
    app.middleware.use(corsMiddleware, at: .beginning) //le .begining assure que le cors soit tjs au debut de la chaine des middleware meme si un autre dev en implemente un au dessus de celui ci.

    app.migrations.add(CreateUser())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateWorkshop())
    app.migrations.add(CreateReservation())
    
    app.asyncCommands.use(SeedCommand(), as: "seed")
    
    // register routes
    try routes(app)
}
