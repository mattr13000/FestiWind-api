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
        let jwtProtectedRoutes = reservations.grouped(JWTMiddleware())
        let staff = jwtProtectedRoutes.grouped(RoleMiddleware(allowedRoles: [.staff]))
        
        jwtProtectedRoutes.post(use: create)
        jwtProtectedRoutes.get("me", use: userReservations)
        jwtProtectedRoutes.group(":id") { reservation in
            reservation.get(use: show)
            reservation.put(use: update)
        }
        
        staff.get(use: index)
        staff.delete(":id", use: delete)
    }
    
    func index(req: Request) async throws -> [WorkshopReservationDTO] {
        let reservations = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .with(\.$user)
            .all()
        return try reservations.map { try $0.toDTO() }
    }
    
    func create(req: Request) async throws -> WorkshopReservationDTO {
        let dto = try req.content.decode(CreateReservationDTO.self)
        
        let payload = try req.auth.require(UserPayload.self)

        guard let user = try await User.find(payload.id, on: req.db),
              let workshop = try await Workshop.find(dto.workshopID, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        guard (workshop.capacityMax - workshop.totalSubscribers) > 0 else
        {
            throw Abort(.conflict)
        }
        
        guard let reservations = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .with(\.$user)
            .filter(\.$user.$id == payload.id)
            .filter(\.$workshop.$id == workshop.id!)
            .first()
        else {
            throw Abort(.conflict)
        }
        
        let reservation = try dto.toModel(userID: payload.id)
        
        try await reservation.create(on: req.db)
        
        reservation.$workshop.value = workshop
        reservation.$user.value = user
        
        return try reservation.toDTO()
    }
    
    func show(req: Request) async throws -> WorkshopReservationDTO {
        guard let id = req.parameters.get("id", as: UUID.self)
        else {throw Abort(.badRequest)}
        
        guard let reservation = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .with(\.$user)
            .filter(\.$id == id)
            .first()
        else {throw Abort(.notFound)}
        
        let payload = try req.auth.require(UserPayload.self)
        guard payload.id == reservation.$user.id else {
            throw Abort(.forbidden, reason: APIError.forbidden.errorDescription)
        }

        
        return try reservation.toDTO()
    }
    
    func userReservations(req: Request) async throws -> UserReservationsDTO {
        let payload = try req.auth.require(UserPayload.self)

        let statuses = [
            ReservationStatus.validated.rawValue,
            ReservationStatus.pending.rawValue
        ]
        
        let reservations = try await Reservation
            .query(on: req.db)
            .with(\.$workshop)
            .with(\.$user)
            .filter(\.$user.$id == payload.id)
            .filter(\.$status ~~ statuses)
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
        
        guard updateData.status == ReservationStatus.cancelled.rawValue else {
            throw Abort(.badRequest)
        }
        
        guard let reservation = try await Reservation.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let payload = try req.auth.require(UserPayload.self)
        guard payload.id == reservation.$user.id else {
            throw Abort(.forbidden, reason: APIError.forbidden.errorDescription)
        }
        
        reservation.status = updateData.status
        
        try await reservation.update(on: req.db)
        
        try await reservation.$workshop.load(on: req.db)
        
        try await reservation.$user.load(on: req.db)
        
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
