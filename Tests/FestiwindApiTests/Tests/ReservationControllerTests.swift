//
//  ReservationControllerTests.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 27/10/2026.
//

@testable import FestiwindApi
import VaporTesting
import Testing
import Fluent


@Suite("ReservationController Tests", .serialized)
struct ReservationControllerTests {
    
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("GET /reservations")
    func getReservations() async throws{
        try await withApp { app in
            let user = try await app.createUser(
                email: "didier@test.com",
                role: .staff
            )
            let token = try app.generateToken(for: user)
            
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            _ = try await app.createWorkshop(
                name: "kite surf",
                startTime: Date(),
                endTime: Date(),
                capacityMax: 32,
                totalSubscribers: 29,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            
            try await app.testing().test(.GET, "reservations", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            }) { res async in
                #expect(res.status == .ok)
            }
        }
    }
    
    @Test("GET reservations/user/:id")
    func getReservationsUser() async throws{
        try await withApp { app in
            let user = try await app.createUser(
                email: "didier@test.com",
                role: .festivalGoer
            )
            let token = try app.generateToken(for: user)
            let userID = try user.requireID()
            
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            _ = try await app.createWorkshop(
                name: "kite surf",
                startTime: Date(),
                endTime: Date(),
                capacityMax: 32,
                totalSubscribers: 29,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            
            try await app.testing().test(.GET, "reservations/user/\(userID)", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            }) { res async in
                #expect(res.status == .ok)
            }
        }
    }
    
    @Test("DELETE /reservations - Expecting noContent")
    func deleteReservation() async throws{
        try await withApp { app in
            let user = try await app.createUser(
                email: "staff_delete@test.com",
                role: .staff
            )
            let token = try app.generateToken(for: user)
            
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            let workshop = try await app.createWorkshop(
                name: "kite surf",
                startTime: Date(),
                endTime: Date(),
                capacityMax: 32,
                totalSubscribers: 29,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            
            let reservation = Reservation(
                status: "pending",
                userID: try user.requireID(),
                workshopID: try workshop.requireID()
            )
            try await reservation.save(on: app.db)
            let reservationID = try reservation.requireID()
            
            try await app.testing().test(.DELETE, "reservations/\(reservationID)", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            }, afterResponse: { res async throws in
                #expect(res.status == .noContent)
            })
        }
    }
    
    @Test("POST /reservations - unauthorized")
    func postReservationNegative() async throws {
        try await withApp { app in
            let categoryDTO = CategoryDTO(
                id: UUID(),
                name: "Bandito"
            )
            try await app.testing().test(.POST, "reservations", beforeRequest: { req in
                try req.content.encode(categoryDTO, as: .json)
            }, afterResponse: { res async throws in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test("POST /reservations - created")
    func postReservationPostivie() async throws {
        try await withApp { app in
            
            let user = try await app.createUser(
                            email: "staff_post@test.com",
                            role: .staff
                        )
            let token = try app.generateToken(for: user)
            
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            let workshop = try await app.createWorkshop(
                name: "kite surf",
                startTime: Date(),
                endTime: Date(),
                capacityMax: 32,
                totalSubscribers: 29,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            
            let createDTO = CreateReservationDTO(
                            userID: try user.requireID(),
                            workshopID: try workshop.requireID()
                        )
            
            try await app.testing().test(.POST, "reservations", beforeRequest: { req in
                req.headers.bearerAuthorization =
                    BearerAuthorization(token: token)
                try req.content.encode(createDTO, as: .json)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })
        }
    }
}
