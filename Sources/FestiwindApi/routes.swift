import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It worjnnnks!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    

    try app.register(collection: ReservationController())
    try app.register(collection: CategoryController())
    try app.register(collection: WorkshopController())
}
