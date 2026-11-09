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
    
    @Test("GET /workshops/:id - show a workshop")
    func getWorkshop() async throws{
        try await withAppIncludingDB { app in
            let user = try await app.createUser(
                email: "didier@test.com",
                role: .festivalGoer
            )
            let token = try app.generateToken(for: user)
            
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            let workshop = try await app.createWorkshop(
                categoryID: try category.requireID()
            )
            
            try await app.testing().test(.GET, "workshops/\(workshop.id!)", beforeRequest: { req async throws in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            },
                                         afterResponse: { res async throws in
                #expect(res.status == .ok)
                let workshopDTO = try                     res.content.decode(WorkshopDTO.self)
                #expect(workshopDTO.name == "kite surf")
                #expect(workshopDTO.capacityMax == 32)
                #expect(workshopDTO.totalSubscribers == 29)
                #expect(workshopDTO.description == "come and surf")
            })
        }
    }
    
    @Test("POST /workshops - Create a workshop")
    func testCreateWorkshop() async throws {
        try await withAppIncludingDB() { app in
            let category = Category(name: "Sport")
            try await category.save(on: app.db)
            
            let user = try await app.createUser(
                email: "staff_post@test.com",
                role: .staff
            )
            let token = try app.generateToken(for: user)
            
            let workshop = CreateWorkshopDTO(
                name: "kite surf",
                startTime: Date(),
                endTime: Date().addingTimeInterval(60),
                capacityMax: 32,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            
            try await app.testing().test(.POST, "workshops",
                                         beforeRequest: { req async throws in
                req.headers.bearerAuthorization =
                BearerAuthorization(token: token)
                try req.content.encode(workshop, as: .json)
            },
                                         afterResponse: { res async throws in
                #expect(res.status == .ok)
                let workshopDTO = try                     res.content.decode(WorkshopDTO.self)
                #expect(workshopDTO.name == "kite surf")
                #expect(workshopDTO.capacityMax == 32)
                #expect(workshopDTO.totalSubscribers == 0)
                #expect(workshopDTO.description == "come and surf")
            })
        }
    }
    
    @Test("UPDATE /workshops/put - update workshop")
    func updateWorkshop() async throws{
        try await withAppIncludingDB { app in
            let user = try await app.createUser(
                            email: "staff_post@test.com",
                            role: .staff
                        )
            let token = try app.generateToken(for: user)
            
            let categoryDTO = CategoryDTO(
                //id: UUID(),
                name: "Didierbogoss"
            )
            let category = categoryDTO.toModel()
            
            try await category.save(on: app.db)

            let categoryID = try category.requireID()
            
            let workshopDTO = CreateWorkshopDTO(
                name: "kite surf",
                startTime: Date(),
                endTime: Date().addingTimeInterval(60),
                capacityMax: 32,
                description: "come and surf",
                categoryID: categoryID
            )
            let workshop = workshopDTO.toModel()
             try await workshop.save(on: app.db)
            let workshopID = try workshop.requireID().uuidString
            
            //let test = try category.requireID().uuidString
            
            let catTest = CategoryDTO(
                id: categoryID,
                name: "Didierbogoss"
            )
            
            print("result user\(user)")
            print("result workshop\(categoryDTO)")
            try await app.testing().test(
                .PUT,
                "workshops/\(workshopID)",
                beforeRequest: { req async throws in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
                let updatedDTO = UpdateWorkshopDTO(
                    id: workshop.id,
                    name: "Didiermoche",
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(60),
                    capacityMax: 32,
                    totalSubscribers: 29,
                    description: "come and surf",
                    category: catTest
                   // category:try category.requireID().uuidString
                )
                    print("result updatedWork\(updatedDTO)")
                    
                try req.content.encode(updatedDTO)
            },
                afterResponse: { res async throws in
                    print("result work \(res)}")
                /*#expect(res.status == .ok)
                let responseDTO = try res.content.decode(WorkshopDTO.self)
                #expect(responseDTO.name == "Didiermoche")*/
            })
        }
    }
    
        @Test("GET /workshops/delete - Delete workshop")
    func deleteWorkshop() async throws{
        try await withAppIncludingDB { app in
            let user = try await app.createUser(
                            email: "staff_delete@test.com",
                            role: .staff
                        )
                        let token = try app.generateToken(for: user)
            
            let categoryDTO = CategoryDTO(
                id: UUID(),
                name: "Didierbogoss"
            )
            let category = categoryDTO.toModel()
            try await category.save(on: app.db)
            _ = try category.requireID().uuidString
            
            let workshopDTO = CreateWorkshopDTO(
                name: "kite surf",
                startTime: Date(),
                endTime: Date().addingTimeInterval(60),
                capacityMax: 32,
                description: "come and surf",
                categoryID: try category.requireID()
            )
            let workshop = workshopDTO.toModel()
            try await workshop.save(on: app.db)
            let workshopID = try workshop.requireID()
            
            try await app.testing().test(.DELETE, "workshops/\(workshopID)", beforeRequest: { req in
                            req.headers.bearerAuthorization = BearerAuthorization(token: token)
                        }, afterResponse: { res async throws in
                            #expect(res.status == .noContent)
                        })
        }
    }
}
