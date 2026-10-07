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

@Suite("UserController Tests", .serialized)
struct UserControllerTests {
    
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

    @Test("GET /users")
    func testIndex() async throws {
        try await withApp { app in
            try await app.createUsers(count: 3)

            try await app.testing().test(.GET, "users", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let users = try res.content.decode([UserDTO].self)
                #expect(users.count == 3)
            })
        }
    }

    @Test("POST /users")
    func testCreate() async throws {
        try await withApp { app in
            let createDTO = CreateUserDTO(
                id: nil,
                name: "New User",
                passwordHash: "supersecurepassword",
                email: "new@test.com",
                role: "festivalGoer",
                createdAt: Date()
            )

            try await app.testing().test(.POST, "users", beforeRequest: { req in
                try req.content.encode(createDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let userDTO = try res.content.decode(UserDTO.self)
                #expect(userDTO.email == "new@test.com")
                #expect(userDTO.name == "New User")
            })
        }
    }

    @Test("POST /users/login -> Positive")
    func testLoginSuccess() async throws {
        try await withApp { app in
            _ = try await app.createUser(
                password: "correctpassword",
                email: "login@test.com"
            )

            let loginDTO = LoginDTO(
                email: "login@test.com",
                password: "correctpassword"
            )

            try await app.testing().test(.POST, "users/login", beforeRequest: { req in
                try req.content.encode(loginDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let authDTO = try res.content.decode(AuthDTO.self)
                #expect(!authDTO.token.isEmpty)
            })
        }
    }

    @Test("POST /users/login -> Negative")
    func testLoginWrongPassword() async throws {
        try await withApp { app in
            _ = try await app.createUser(
                password: "correctpassword",
                email: "login@test.com"
            )

            let loginDTO = LoginDTO(
                email: "login@test.com",
                password: "wrongpassword"
            )

            try await app.testing().test(.POST, "users/login", beforeRequest: { req in
                try req.content.encode(loginDTO)
            }, afterResponse: { res async in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("GET /users/profile")
    func testProfile() async throws {
        try await withApp { app in
            let user = try await app.createUser(email: "profile@test.com")
            let token = try app.generateToken(for: user)

            try await app.testing().test(.GET, "users/profile", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let userDTO = try res.content.decode(UserDTO.self)
                #expect(userDTO.email == "profile@test.com")
            })
        }
    }

    @Test("GET /users/:userID")
    func testGetUserById() async throws {
        try await withApp { app in
            let user = try await app.createUser(email: "byid@test.com")
            let userToken = try app.generateToken(for: user)
            let userID = try user.requireID()

            try await app.testing().test(.GET, "\(userID)", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: userToken)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let userDTO = try res.content.decode(UserDTO.self)
                #expect(userDTO.id == userID)
                #expect(userDTO.email == "byid@test.com")
            })
        }
    }
}
