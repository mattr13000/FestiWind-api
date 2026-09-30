//
//  UserReservationsDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct UserReservationsDTO: Content {
    let workshopReservationsDTO: [WorkshopReservationDTO]
    
    init(reservations: [Reservation]) throws {
        self.workshopReservationsDTO = try reservations.map({try $0.toDTO()})
   }
}
