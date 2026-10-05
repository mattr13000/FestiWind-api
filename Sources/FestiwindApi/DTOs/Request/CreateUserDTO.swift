//
//  UserDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

import Vapor

struct CreateUserDTO: Content {
    let id: UUID?
    let name: String
    var passwordHash: String
    let email: String
    let role: String
    let createdAt: Date
}

extension CreateUserDTO {
    func toModel() -> User {
        return User(
            name: name,
            passwordHash: passwordHash,
            email: email,
            role: role,
            createdAt: createdAt
        )
    }
}
