//
//  EventReservationDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 29/09/2026.
//

import Vapor

struct EventReservationDTO: Content {
    let status: String
    let eventName: String
    let startTime: Date
    let endTime: Date
}
