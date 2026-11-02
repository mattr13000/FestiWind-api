//
//  CategoryControllerTests.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 28/10/2026.
//
@testable import FestiwindApi
import VaporTesting
import Testing
import Fluent


@Suite("CategoryController Tests", .serialized)
struct CategoryControllerTests {
    
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

    @Test("GET /categories")
    func getCategories() async throws{
        try await withApp { app in
            try await app.testing().test(.GET, "categories") { res async in
                #expect(res.status == .ok)
            }
        }
    }
    
    @Test("POST /categories - unauthorized")
    func postCategoryNegative() async throws{
        try await withApp { app in
            let categoryDTO = CategoryDTO(
                id: UUID(),
                name: "Bandito"
            )
            try await app.testing().test(.POST, "categories", beforeRequest: { req in
                try req.content.encode(categoryDTO, as: .json)
            }, afterResponse: { res async throws in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test("POST /categories - Expecting ok")
    func postCategoryPositive() async throws{
        try await withApp { app in
            
            let user = try await app.createUser(
                            email: "staff_post@test.com",
                            role: .staff
                        )
            let token = try app.generateToken(for: user)
            
            let categoryDTO = CategoryDTO(
                id: UUID(),
                name: "Didierbogoss"
            )
            try await app.testing().test(.POST, "categories", beforeRequest: { req in
                req.headers.bearerAuthorization =
                    BearerAuthorization(token: token)
                try req.content.encode(categoryDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })
        }
    }
    
    @Test("DELETE /categories - Expecting noContent")
    func deleteCategory() async throws{
        try await withApp { app in
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
            let categoryID = try category.requireID().uuidString
            
            try await app.testing().test(.DELETE, "categories/\(categoryID)", beforeRequest: { req in
                            req.headers.bearerAuthorization = BearerAuthorization(token: token)
                        }, afterResponse: { res async throws in
                            #expect(res.status == .noContent)
                        })
        }
    }
    
    @Test("UPDATE /categories")
    func updateCategory() async throws{
        try await withApp { app in
            let user = try await app.createUser(
                            email: "staff_post@test.com",
                            role: .staff
                        )
            let token = try app.generateToken(for: user)
            
            let categoryDTO = CategoryDTO(
                id: UUID(),
                name: "Didierbogoss"
            )
            let category = categoryDTO.toModel()
            try await category.save(on: app.db)
            let categoryID = try category.requireID().uuidString
            
            try await app.testing().test(.PUT, "categories/\(categoryID)", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
                let updatedDTO = CategoryDTO(id: categoryDTO.id, name: "Didiermoche")
                try req.content.encode(updatedDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                
                let responseDTO = try res.content.decode(CategoryDTO.self)
                #expect(responseDTO.name == "Didiermoche")
            })
        }
    }
}
