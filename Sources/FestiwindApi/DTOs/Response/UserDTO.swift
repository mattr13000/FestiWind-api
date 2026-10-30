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
    let email: String
    let role: UserRole
    let createdAt: Date
}
