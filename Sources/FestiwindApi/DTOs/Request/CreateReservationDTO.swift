//
//  ReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct CreateReservationDTO: Content {
    let userID: UUID
    let workshopID: UUID
}

extension CreateReservationDTO {
    func toModel() throws -> Reservation {
        return Reservation (
            status: "Ok",
            userID: userID,
            workshopID: workshopID
        )
    }
}

