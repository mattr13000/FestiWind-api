//
//  Category.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

//Category
//‣ Id
//‣ Name

import Vapor
import Fluent
import struct Foundation.UUID

final class Category: Content, Model, @unchecked Sendable {
    static let schema = "categories"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Children(for: \.$category)
    var workshops: [Workshop]
    
    init() {}
    
    init(id: UUID? = nil,
         name: String) {
        self.id = id
        self.name = name
    }
}

extension Category {
    func toUpdateDTO() throws -> CategoryDTO {
        return CategoryDTO(
            id: try requireID(),
            name: name
        )
    }
}
