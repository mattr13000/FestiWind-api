//
//  SeedCommand.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 30/09/2026.
//

import Vapor
import Fluent

struct SeedCommand: AsyncCommand {
    struct Signature: CommandSignature { }

    var help: String {
        "Generate mock-up data for local testing."
    }

    func run(using context: CommandContext, signature: Signature) async throws {
        let database = context.application.db
        
        context.console.info("Cleaning DB ...")
        try await Reservation.query(on: database).delete()
        try await Workshop.query(on: database).delete()
        try await User.query(on: database).delete()
        try await Category.query(on: database).delete()

        context.console.info("Seeding ...")

        let categories = [
            Category(id: UUID(), name: "Initiation & Fabrique"),
            Category(id: UUID(), name: "Démonstration & Vol Libre"),
            Category(id: UUID(), name: "Pilotage Acrobatique"),
            Category(id: UUID(), name: "Atelier Scientifique & Vent")
        ]
        for category in categories {
            try await category.save(on: database)
        }

        let roles = ["user", "user", "user", "admin", "organizer"]
        var users: [User] = []
        for i in 0..<20 {
            let user = User(
                id: UUID(),
                name: "Utilisateur \(i)",
                passwordHash: "hash_fictif",
                email: "user\(i)@festiwind.fr",
                role: roles[i % roles.count],
                createdAt: Date()
            )
            try await user.save(on: database)
            users.append(user)
        }

        var workshops: [Workshop] = []
        for i in 0..<20 {
            let workshop = Workshop(
                id: UUID(),
                name: "Atelier \(i)",
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                capacityMax: 15,
                totalSubscribers: 0,
                description: "Description \(i)",
                categoryID: categories[i % categories.count].id!
            )
            try await workshop.save(on: database)
            workshops.append(workshop)
        }

        let statuses = ["confirmed", "pending", "cancelled"]
        for i in 0..<20 {
            let selectedWorkshop = workshops[i % workshops.count]
            let selectedUser = users[i % users.count]
            let status = statuses[i % statuses.count]

            let reservation = Reservation(
                id: UUID(),
                status: status,
                userID: selectedUser.id!,
                workshopID: selectedWorkshop.id!
            )
            try await reservation.save(on: database)

            if status == "confirmed" {
                selectedWorkshop.totalSubscribers += 1
                try await selectedWorkshop.save(on: database)
            }
        }

        context.console.success("Success")
    }
}
