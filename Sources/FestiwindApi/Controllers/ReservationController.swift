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
    
    func index(req: Request) async throws -> [Reservation] {
        return try await Reservation
            .query(on: req.db)
            .all()
    }
    
    func create(req: Request) async throws -> Reservation {
        let dto = try req.content.decode(CreateReservationDTO.self)
        
        guard let user = try await User.find(dto.userID, on: req.db),
              let workshop = try await Workshop.find(dto.workshopID, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        let reservation = try dto.toModel()
        
        try await reservation.create(on: req.db)
        return reservation
    }
    
    func show(req: Request) async throws -> Reservation {
        
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let reservation = try await Reservation.find(id, on: req.db)
        else {throw Abort(.notFound)}

        
        return reservation
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
            reservations
        )
        return userReservations
    }
    
    func update(req: Request) async throws -> Reservation {
        
        guard let id = req.parameters.get("id", as: UUID.self)
                
        else {throw Abort(.badRequest)}
        
        guard let reservation = try await Reservation.find(id, on: req.db)
                
        else {throw Abort(.notFound)}
        
        let newReservation = try req.content.decode(Reservation.self)
        
        guard !newReservation.status.isEmpty
        
        else {throw Abort(.badRequest)}
        
        reservation.status = newReservation.status
        reservation.user.id = newReservation.user.id
        reservation.workshop.id = newReservation.workshop.id
        
        try await reservation.update(on: req.db)
        
        return reservation
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
