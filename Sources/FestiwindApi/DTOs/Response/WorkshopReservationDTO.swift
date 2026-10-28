//
//  EventReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct WorkshopReservationDTO: Content {
    let id: UUID
    let status: String
    let userName: String
    let workshopName: String
    let startTime: Date
    let endTime: Date
}
