//
//  ReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct CreateReservationDTO: Content {
    let workshopID: UUID
}

extension CreateReservationDTO {
    func toModel(userID: UUID) throws -> Reservation {
        return Reservation (
            status: ReservationStatus.validated.rawValue,
            userID: userID,
            workshopID: workshopID
        )
    }
}
