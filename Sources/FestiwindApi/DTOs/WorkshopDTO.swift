import Vapor
import Fluent

struct WorkshopDTO: Content {
    var id: UUID?
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var totalSubscribers: Int
    var description: String
    var categoryID: UUID
    
    func toModel() -> Workshop {
        let workshop = Workshop (
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            totalSubscribers: totalSubscribers,
            description: description,
            categoryID: categoryID
        )
        return workshop
    }
}

