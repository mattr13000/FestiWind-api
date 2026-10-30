//
//  LoginDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 01/10/2026.
//

import Vapor

struct LoginDTO: Content {
    let email: String
    let password: String
}
