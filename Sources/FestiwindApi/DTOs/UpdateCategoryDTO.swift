//
//  UpdateCategoryDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 29/09/2026.
//

import Vapor
import Fluent

struct UpdateCategoryDTO: Content {
    var id: UUID
    var name: String
}


