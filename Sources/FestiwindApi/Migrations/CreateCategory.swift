//
//  CreateCategory.swift
//  Vapor_FestiWind
//
//  Created by Apprenant 87 on 28/09/2026.
//

import Fluent

struct CreateCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database
            .schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on databse: any Database) async throws {
        try await databse
            .schema(Category.schema)
            .delete()
    }
}
