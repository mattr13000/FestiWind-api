//
//  UserDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 01/10/2026.
//

import Vapor

struct UserDTO: Content {
    let id: UUID?
    let name: String
    let passwordHash: String
    let email: String
    let role: String
    let createdAt: Date
}

extension UserDTO {
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
