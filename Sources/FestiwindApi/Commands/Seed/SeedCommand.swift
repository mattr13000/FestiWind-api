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
        "Fill the database with mock-up data for local testing."
    }

    private let staffCount = 4
    private let daysBeforeFestival = 7
    private let partialFillRates = [0.4, 0.6, 0.8, 0.25]

    func run(using context: CommandContext, signature: Signature) async throws {
        let database = context.application.db
        let now = Date()

        context.console.info("Cleaning DB ...")
        try await Reservation.query(on: database).delete()
        try await Workshop.query(on: database).delete()
        try await User.query(on: database).delete()
        try await Category.query(on: database).delete()

        context.console.info("Inserting mock-up data ...")
        let categories = try await insertCategories(on: database)
        let festivalGoers = try await insertUsers(now: now, on: database)
        let planned = planWorkshops(categories: categories, now: now)
        let reservationCount = try await insertWorkshopsAndReservations(planned, users: festivalGoers, on: database)

        context.console.success("Success : \(categories.count) catégories, \(festivalGoers.count + staffCount + 1) users, \(planned.count) ateliers, \(reservationCount) réservations")

        let full = planned.filter(\.isFull)
        context.console.info("Ateliers pleins (\(full.count)/\(planned.count)) :")
        for item in full {
            let w = item.workshop
            context.console.info("  • \(w.name) — \(w.startTime.formatted(date: .abbreviated, time: .shortened)) — \(w.totalSubscribers)/\(w.capacityMax)")
        }
        context.console.info("Staff login: staff@festiwind.fr / staff1234")
        context.console.info("FestivalGoer login: user0@festiwind.fr / password123")
    }
}

private extension SeedCommand {
    struct PlannedWorkshop {
        let workshop: Workshop
        let isFull: Bool
    }

    func insertCategories(on database: any Database) async throws -> [Category] {
        var categories: [Category] = []
        for template in SeedData.categories {
            let category = Category(id: UUID(), name: template.name)
            try await category.save(on: database)
            categories.append(category)
        }
        return categories
    }

    func insertUsers(now: Date, on database: any Database) async throws -> [User] {
        let passwordHash = try Bcrypt.hash("password123")

        let staffUser = User(
            id: UUID(),
            name: "Staff",
            passwordHash: try Bcrypt.hash("staff1234"),
            email: "staff@festiwind.fr",
            role: .staff,
            createdAt: now.addingTimeInterval(-90 * 86_400)
        )
        try await staffUser.save(on: database)

        let user0 = User(
            id: UUID(),
            name: "Utilisateur 0",
            passwordHash: passwordHash,
            email: "user0@festiwind.fr",
            role: .festivalGoer,
            createdAt: now.addingTimeInterval(-60 * 86_400)
        )
        try await user0.save(on: database)

        var festivalGoers = [user0]
        for (index, name) in SeedData.userNames.enumerated() {
            let isStaff = index < staffCount
            let user = User(
                id: UUID(),
                name: "\(name.first) \(name.last)",
                passwordHash: passwordHash,
                email: SeedData.email(first: name.first, last: name.last, domain: isStaff ? "festiwind.fr" : "exemple.fr"),
                role: isStaff ? .staff : .festivalGoer,
                createdAt: now.addingTimeInterval(-Double(index + 1) * 86_400)
            )
            try await user.save(on: database)
            if !isStaff { festivalGoers.append(user) }
        }
        return festivalGoers
    }

    func planWorkshops(categories: [Category], now: Date) -> [PlannedWorkshop] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        let festivalStart = calendar.date(byAdding: .day, value: daysBeforeFestival, to: calendar.startOfDay(for: now))!

        var planned: [PlannedWorkshop] = []
        for (category, template) in zip(categories, SeedData.categories) {
            for workshopTemplate in template.workshops {
                for session in workshopTemplate.sessions {
                    let day = calendar.date(byAdding: .day, value: session.day, to: festivalStart)!
                    let start = calendar.date(bySettingHour: session.hour, minute: session.minute, second: 0, of: day)!

                    let workshop = Workshop(
                        id: UUID(),
                        name: workshopTemplate.name,
                        startTime: start,
                        endTime: start.addingTimeInterval(Double(workshopTemplate.durationMinutes) * 60),
                        capacityMax: workshopTemplate.capacity,
                        totalSubscribers: 0,
                        description: workshopTemplate.description,
                        categoryID: category.id!
                    )
                    planned.append(PlannedWorkshop(workshop: workshop, isFull: session.isFull))
                }
            }
        }
        return planned.sorted { $0.workshop.startTime < $1.workshop.startTime }
    }

    func insertWorkshopsAndReservations(_ planned: [PlannedWorkshop], users: [User], on database: Database) async throws -> Int {
        var validatedSlots: [UUID: [(start: Date, end: Date)]] = [:]
        var reservationCount = 0

        let ordered = planned.filter(\.isFull) + planned.filter { !$0.isFull }

        for (index, item) in ordered.enumerated() {
            let workshop = item.workshop
            var reservations: [Reservation] = []
            var validatedCount = 0

            let offset = (index * 5) % users.count
            let rotation = Array(users[offset...] + users[..<offset])

            func isAvailable(_ user: User) -> Bool {
                !validatedSlots[user.id!, default: []].contains { $0.start < workshop.endTime && workshop.startTime < $0.end }
            }

            let target = item.isFull
                ? workshop.capacityMax
                : min(Int(Double(workshop.capacityMax) * partialFillRates[index % partialFillRates.count]),
                      workshop.capacityMax - 1)

            for user in rotation where validatedCount < target {
                guard isAvailable(user) else { continue }
                validatedCount += 1
                validatedSlots[user.id!, default: []].append((workshop.startTime, workshop.endTime))
                reservations.append(Reservation(id: UUID(), status: "validated", userID: user.id!, workshopID: workshop.id!))
            }

            if item.isFull && validatedCount != workshop.capacityMax {
                throw Abort(.internalServerError, reason: "Impossible de remplir « \(workshop.name) » (\(validatedCount)/\(workshop.capacityMax)). Ajoute des users.")
            }

            workshop.totalSubscribers = validatedCount
            try await workshop.save(on: database)
            for reservation in reservations {
                try await reservation.save(on: database)
            }
            reservationCount += reservations.count
        }
        return reservationCount
    }
}
