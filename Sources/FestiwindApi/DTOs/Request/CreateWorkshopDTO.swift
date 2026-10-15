import Vapor
import Fluent

struct CreateWorkshopDTO: Content {
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var description: String
    var category: String
}



