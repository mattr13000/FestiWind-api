//
//  CreateCategory.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

//@ID(key: .id)
//var id: UUID?
//
//@Field(key: "name")
//var name: String
//
//@Children(for: \.$category)
//var workshops: [Workshop]

import Fluent

struct CreateCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database
            .schema(Category.schema)
            .id()
            .field(
                "name",
                .string,
                .required
            )
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database
            .schema(Category.schema)
            .delete()
    }
}
