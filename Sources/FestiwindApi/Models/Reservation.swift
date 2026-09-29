//
//  Reservation.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

//Reservation
//‣ Id
//‣ Workshop Id
//‣ User Id
//‣ Status (validée/en attente/annulée)

import Vapor
import Fluent
import struct Foundation.UUID

final class Reservation: Content, Model, @unchecked Sendable {
    static let schema = "reservations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "workshop_id")
    var workshop: Workshop
    
    init() {}
    
    init(id: UUID? = nil,
         status: String,
         userID: UUID,
         workshopID: UUID) {
        self.id = id
        self.status = status
        self.$user.id = userID
        self.$workshop.id = workshopID
    }
}


