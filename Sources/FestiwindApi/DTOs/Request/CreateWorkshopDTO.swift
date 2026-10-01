import Vapor
import Fluent

struct CreateWorkshopDTO: Content {
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var totalSubscribers: Int
    var description: String
    var categoryID: UUID
}
