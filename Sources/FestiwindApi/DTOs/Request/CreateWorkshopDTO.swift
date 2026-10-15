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
    
    func toModel() -> Workshop {
        return Workshop(
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            totalSubscribers: totalSubscribers,
            description: description,
            categoryID: categoryID)
    }
}
