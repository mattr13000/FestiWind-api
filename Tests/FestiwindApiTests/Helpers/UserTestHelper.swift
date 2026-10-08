//
//  TestHelpers.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 07/10/2026.
//

@testable import FestiwindApi
import Vapor
import Fluent
import JWT

extension Application {
    @discardableResult
    func createUser(
        name: String = "Didier",
        password: String = "password123",
        email: String = "didier@test.com",
        role: String = "festivalGoer",
        createdAt: Date = Date()
    ) async throws -> User {
        let hashedPassword = try Bcrypt.hash(password)
        
        let user = User(
            name: name,
            passwordHash: hashedPassword,
            email: email,
            role: role,
            createdAt: createdAt
        )
        try await user.save(on: self.db)
        return user
    }

    @discardableResult
    func createUsers(
        count: Int,
        role: String = "festivalGoer"
    ) async throws -> [User] {
        var users: [User] = []
        for i in 1...count {
            let user = try await self.createUser(
                name: "User Test \(i)",
                email: "user\(i))@test.com",
                role: role
            )
            users.append(user)
        }
        return users
    }
    
    func generateToken(for user: User) throws -> String {
            let payload = UserPayload(id: try user.requireID())
            let signer = JWTSigner.hs256(key: "stringmaisadressmailaussiazertyavecselpoivresaladtomatogno")
            return try signer.sign(payload)
        }
}
