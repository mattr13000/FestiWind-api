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

    @Test("GET /Category")
    func testIndex() async throws{
        try await withApp { app in
            
        }
    }
}
