//
//  WorkshopController.swift
//  FestiwindApi
//
//  Created by Apprenant 72 on 29/09/2026.
//

import Fluent
import Vapor

struct WorkshopController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let workshop = routes.grouped("workshop")
        workshop.get(use: index)
        workshop.post(use: create)
        workshop.group(":id") { workshop in
            workshop.get(use: show)
            workshop.post(use: update)
            workshop.delete(use: delete)
        }
    }
        
    // ************ index **********************************
    func index(req: Request) async throws -> [WorkshopDTO] {
    let workshops = try await Workshop
        .query(on: req.db)
        .all()

    return workshops.map { workshop in
        WorkshopDTO(
            id: workshop.id,
            name: workshop.name,
            startTime: workshop.startTime,
            endTime: workshop.endTime,
            capacityMax: workshop.capacityMax,
            totalSubscribers: workshop.totalSubscribers,
            description: workshop.description,
            categoryID: workshop.$category.id
        )
    }
}
   // ************ fin index **********************************

//*************  Create ************************************
func create(req: Request) async throws -> Workshop {
    let dto = try req.content.decode(CreateWorkshopDTO.self)

    let workshop = Workshop()
    workshop.name = dto.name
    workshop.startTime = dto.startTime
    workshop.endTime = dto.endTime
    workshop.capacityMax = dto.capacityMax
    workshop.totalSubscribers = dto.totalSubscribers
    workshop.description = dto.description
    workshop.$category.id = dto.categoryID

    try await workshop.create(on: req.db)

    return workshop
}
//************* fin create ************************************
    
    func show(req: Request) async throws -> Workshop {
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let workshop = try await Workshop.find(id, on:req.db)
        else{throw Abort(.notFound)}
        
        return workshop
    }
    
    func update (req: Request) async throws -> Workshop {
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let workshop = try await Workshop.find(id , on: req.db)
        else { throw Abort(.notFound)}
        
        let newWorkshop = try req.content.decode(Workshop.self)
        workshop.name = newWorkshop.name
        workshop.startTime = newWorkshop.startTime
        workshop.endTime = newWorkshop.endTime
        workshop.description = newWorkshop.description
        workshop.capacityMax = newWorkshop.capacityMax
        workshop.totalSubscribers = newWorkshop.totalSubscribers
        workshop.category = newWorkshop.category
        
        try await workshop.update(on: req.db)
        return workshop
    }
    
    func delete (req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self)
        else{throw Abort(.badRequest)}
        
        guard let workshop = try await Workshop.find(id, on: req.db)
        else {throw Abort(.notFound)}
        
        try await workshop.delete(on: req.db)
        return .noContent
    }
}
