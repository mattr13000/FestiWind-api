//
//  ReservationTestHelper.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 30/10/2026.
//

@testable import FestiwindApi
import Vapor
import Fluent
import JWT

extension Application {
    @discardableResult
    func createWorkshop(
        name: String = "kite surf",
        startTime: Date = Date(),
        endTime: Date = Date(),
        capacityMax: Int = 32,
        totalSubscribers: Int = 29,
        description: String = "come and surf",
        categoryID: UUID
    ) async throws -> Workshop {
        let workshop = Workshop(
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            totalSubscribers: totalSubscribers,
            description: description,
            categoryID: categoryID
        )
        try await workshop.save(on: self.db)
        return workshop
    }
}
