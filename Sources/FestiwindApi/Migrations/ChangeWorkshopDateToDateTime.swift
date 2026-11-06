//
//  ChangeWorkshopDateToDateTIme.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 06/11/2026.
//

import Fluent

struct ChangeWorkshopDateToDateTime: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("workshops")
            .updateField("start_time", .datetime)
            .updateField("end_time", .datetime)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("workshops")
            .updateField("start_time", .date)
            .updateField("end_time", .date)
            .update()
    }
}
