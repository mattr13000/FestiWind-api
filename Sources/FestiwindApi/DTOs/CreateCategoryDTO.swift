//
//  PostCategoryDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 29/09/2026.
//

import Vapor
import Fluent

struct CreateCategoryDTO: Content {
    var name: String
}

extension CreateCategoryDTO {
    func toModel() -> Category {
        return Category(name: name)
    }
}

