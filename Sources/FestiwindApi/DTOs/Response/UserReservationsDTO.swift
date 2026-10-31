//
//  UserReservationsDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct UserReservationsDTO: Content {
    let reservationDTO: [ReservationDTO]
    
    init(reservations: [Reservation]) throws {
        self.reservationDTO = try reservations.map({try $0.toDTO()})
   }
}
