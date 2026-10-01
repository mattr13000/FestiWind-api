//
//  UpdateReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 30/09/2026.
//

import Vapor

struct UpdateReservationDTO: Content {
    let status: String
    let userID: UUID
    let workshopID: UUID
}

extension UpdateReservationDTO {
    func toModel() throws -> Reservation {
        return Reservation (
            status: status,
            userID: userID,
            workshopID: workshopID
        )
    }
}

