//
//  CreateUser.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database
            .schema(User.schema)
            .id()
            .field(
                "name",
                .string,
                .required
            )
            .field(
                "password_hash",
                .string,
                .required
            )
            .field(
                "email",
                .string,
                .required
            )
            .field(
                "role",
                .string,
                .required,
            )
            .field(
                "created_at",
                .date,
                .required,
            )
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database
            .schema(User.schema)
            .delete()
    }
}
