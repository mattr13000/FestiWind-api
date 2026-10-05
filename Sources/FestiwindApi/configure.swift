import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import Gatekeeper

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
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 800
    )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfig)
    
    //------------------- Middlewares ----------------------
    
    //CORS
    app.middleware.use(corsMiddleware, at: .beginning) //le .begining assure que le cors soit tjs au debut de la chaine des middleware meme si un autre dev en implemente un au dessus de celui ci.
    
    //Gatekeeper
    app.caches.use(.memory) //stockage des compteurs
    app.gatekeeper.config = .init(maxRequests: 100, per: .minute) // contraintes que l'on veut appliquer
    app.middleware.use(GatekeeperMiddleware()) // activation du middleware
 
    //------------------- Migrations ----------------------

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .any(["http://127.0.0.1:8081"]),
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 800
    )
    
    app.middleware.use(corsMiddleware)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateWorkshop())
    app.migrations.add(CreateReservation())
    
    
    //------------------- Services ----------------------
    app.asyncCommands.use(SeedCommand(), as: "seed")
    
    // register routes
    try routes(app)
}
