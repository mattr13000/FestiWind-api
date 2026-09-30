//
//  ReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

//.field(
//    "status",
//    .string,
//    .required
//)
//.field(
//    "user_id",
//    .uuid,
//    .required,
//    .references(User.schema, "id")
//)
//.field(
//    "workshop_id",
//    .uuid,
//    .required,
//    .references(Workshop.schema, "id")
//)

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

