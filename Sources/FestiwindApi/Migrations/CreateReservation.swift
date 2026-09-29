//
//  CreateReservation.swift
//  Vapor_FestiWind
//
//  Created by Apprenant 87 on 28/09/2026.
//
import Fluent

struct CreateReservation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database
            .schema(Reservation.schema)
            .id()
            .field("Status", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database
            .schema(Reservation.schema)
            .delete()
    }
}
