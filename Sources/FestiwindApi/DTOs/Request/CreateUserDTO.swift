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
    let password: String
    let email: String
}

extension CreateUserDTO {
    func toModel(passwordHash: String) -> User {
        return User(
            name: name,
            passwordHash: passwordHash,
            email: email,
            role: .festivalGoer,
            createdAt: Date()
        )
    }
}
