//
//  Workshop.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//

//Workshop
//‣ Id
//‣ Name
//‣ Category Id (en fonction du thème du festival)
//‣ Start Time
//‣ End Time
//‣ Capacity Max
//‣ Total Subscribers (le nombre de personne inscrites)
//‣ Description

import Vapor
import Fluent
import struct Foundation.UUID


final class Workshop: Content, Model, @unchecked Sendable {
    static let schema = "workshops"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
//    @Field(key: "category_id")
//    var categoryID: Type?
    
    @Field(key: "start_time")
    var startTime: Date
    
    @Field(key: "end_time")
    var endTime: Date
    
    @Field(key: "capacity_max")
    var capacityMax: Int
    
    @Field(key: "total_subscribers")
    var totalSubscribers: Int
    
    @Field(key: "description")
    var description: String
    
    init() {}
    
    init(id: UUID? = nil,
         name: String,
         startTime: Date,
         endTime: Date,
         capacityMax: Int,
         totalSubscribers: Int) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.capacityMax = capacityMax
        self.totalSubscribers = totalSubscribers
    }
}
