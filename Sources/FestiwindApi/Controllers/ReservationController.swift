//
//  ReservationController.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor
import Fluent

struct ReservationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reservations = routes.grouped("reservations")
        
        reservations.get(use: index)
        reservations.post(use: create)
        reservations.get("user", ":id", use: userReservations)
        reservations.group(":id") { reservation in
            reservation.get(use: show)
            reservation.put(use: update)
            reservation.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [WorkshopReservationDTO] {
        let reservations = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .all()
        return try reservations.map { try $0.toDTO() }
    }
    
    func create(req: Request) async throws -> WorkshopReservationDTO {
        let dto = try req.content.decode(CreateReservationDTO.self)
        
        guard let _ = try await User.find(dto.userID, on: req.db),
              let workshop = try await Workshop.find(dto.workshopID, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        let reservation = try dto.toModel()
        
        try await reservation.create(on: req.db)
        
        reservation.$workshop.value = workshop
        
        return try reservation.toDTO()
    }
    
    func show(req: Request) async throws -> WorkshopReservationDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let reservation = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .filter(\.$id == id)
            .first()
                
        else {throw Abort(.notFound)}
        
        
        return try reservation.toDTO()
    }
    
    func userReservations(req: Request) async throws -> UserReservationsDTO {
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        let reservations = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .filter(\.$user.$id == id)
            .all()
        
        let userReservations = try UserReservationsDTO(reservations:
            reservations)
        return userReservations
    }
    
    func update(req: Request) async throws -> WorkshopReservationDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
       
        let updateData = try req.content.decode(UpdateReservationDTO.self)
        
        guard !updateData.status.isEmpty else {
            throw Abort(.badRequest)
        }
        
        guard let reservation = try await Reservation.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        reservation.status = updateData.status
        reservation.$user.id = updateData.userID
        reservation.$workshop.id = updateData.workshopID
        
        try await reservation.update(on: req.db)
        
        try await reservation.$workshop.load(on: req.db)
        
        return try reservation.toDTO()
    }
    
    
    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let reservation = try await Reservation.find(id, on: req.db)
        else {throw Abort(.notFound)}
        
        try await reservation.delete(on: req.db)
        
        return .noContent
    }
}
