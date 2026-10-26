//
//  UserControllerTests.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 07/10/2026.
//

@testable import FestiwindApi
import VaporTesting
import Testing
import Fluent

@Suite("WorkshopController Tests", .serialized)
struct WorkshopControllerTests {
    
    private func withAppIncludingDB(
        _ test: (Application) async throws -> Void
    ) async throws {
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
    
    @Test("GET /workshops - List all workshops")
    func getWorkshops() async throws {
        try await withAppIncludingDB { app in
            try await app.testing().test(.GET, "workshops") { res async in
                #expect(res.status == .ok)
                //#expect(res.body.string == "Hello, world!")
            }
        }
    }
    @Test("POST /workshops - Create a workshop")
    func createWorkshop() async throws {
        try await withAppIncludingDB() { app in
            let newWorkshop = CreateWorkshopDTO(name: "Workshop1", startTime: Date(), endTime: Date(), capacityMax: 10, description: "A new workshop", categoryID: UUID())
            try await app.testing().test(
                .POST,
                "workshops",
                beforeRequest: {
                    req in try req.content.encode(newWorkshop, as: .json)
                },
                afterResponse: {
                    res async in
                    #expect(res.status == .ok || res.status == .created)
                }
            )
        }
    }
}
