//
//  User.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

//User (avec un rôle : staff ou festivalGoer)
//‣ Id
//‣ Name
//‣ Password Hash
//‣ Email
//‣ Role
//‣ Created At

import Vapor
import Fluent
import struct Foundation.UUID


final class User: Content, Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "created_at")
    var createdAt: Date
    
    @Children(for: \.$user)
    var reservations: [Reservation]
    
    init() {}
    
    init(id: UUID? = nil,
         name: String,
         passwordHash: String,
         email: String,
         role: String,
         createdAt: Date) {
        self.id = id
        self.name = name
        self.passwordHash = passwordHash
        self.email = email
        self.role = role
        self.createdAt = createdAt
    }
}

extension User {
    func toDTO() throws -> UserDTO {
        return UserDTO(
            id: try requireID(),
            name: name,
            passwordHash: passwordHash,
            email: email,
            role: role,
            createdAt: createdAt)
    }
}
