//
//  SeedData.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 04/11/2026.
//

import Foundation

enum SeedData {
    struct CategoryTemplate {
        let name: String
        let workshops: [WorkshopTemplate]
    }

    struct WorkshopTemplate {
        let name: String
        let description: String
        let durationMinutes: Int
        let capacity: Int
        let sessions: [Session]
    }

    struct Session {
        let day: Int
        let hour: Int
        let minute: Int
        var isFull = false
    }

    static let firstNames = [
        "Lucas", "Emma", "Hugo", "Léa", "Louis", "Chloé", "Gabriel", "Manon", "Arthur", "Inès",
        "Jules", "Sarah", "Nathan", "Zoé", "Théo", "Jade", "Raphaël", "Lina", "Noah", "Anaïs"
    ]

    static let lastNames = [
        "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit", "Durand", "Leroy", "Moreau", "Simon",
        "Laurent", "Lefèvre", "Michel", "Garcia", "David", "Bertrand", "Roux", "Vincent", "Fournier", "Morel"
    ]

    static var userNames: [(first: String, last: String)] {
        let straight = zip(firstNames, lastNames).map { (first: $0, last: $1) }
        let reversed = zip(firstNames, lastNames.reversed()).map { (first: $0, last: $1) }
        return straight + reversed
    }

    static func email(first: String, last: String, domain: String) -> String {
        func clean(_ s: String) -> String {
            s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: "'", with: "")
        }
        return "\(clean(first)).\(clean(last))@\(domain)"
    }

    static let categories: [CategoryTemplate] = [
        .init(name: "Initiation & Fabrique", workshops: [
            .init(name: "Fabrique ton cerf-volant losange",
                  description: "Découpe, collage et montage d'un cerf-volant classique en papier kraft et baguettes de bambou. Repars avec ton cerf-volant !",
                  durationMinutes: 90, capacity: 12,
                  sessions: [.init(day: 0, hour: 10, minute: 0, isFull: true),
                             .init(day: 2, hour: 14, minute: 0)]),
            .init(name: "Atelier enfants : mini cerf-volant",
                  description: "Pour les 6-10 ans : un petit cerf-volant en papier de soie à décorer, prêt à voler en fin d'atelier.",
                  durationMinutes: 60, capacity: 15,
                  sessions: [.init(day: 0, hour: 14, minute: 0),
                             .init(day: 1, hour: 10, minute: 30)]),
            .init(name: "Initiation au cerf-volant monofil",
                  description: "Les bases : lancer, tenir le vent, récupérer sa ligne. Idéal pour débuter, matériel fourni.",
                  durationMinutes: 60, capacity: 20,
                  sessions: [.init(day: 1, hour: 11, minute: 0)]),
            .init(name: "Réparer et entretenir sa voile",
                  description: "Rustines, coutures, remplacement de baguettes : apprends à donner une seconde vie à ton matériel.",
                  durationMinutes: 45, capacity: 10,
                  sessions: [.init(day: 2, hour: 16, minute: 0)])
        ]),
        .init(name: "Démonstration & Vol Libre", workshops: [
            .init(name: "Parade des cerfs-volants géants",
                  description: "Démonstration de structures gonflables de plus de 20 m par des équipes internationales. Accès libre au périmètre spectateurs.",
                  durationMinutes: 60, capacity: 80,
                  sessions: [.init(day: 1, hour: 15, minute: 0)]),
            .init(name: "Ballet nocturne lumineux",
                  description: "Cerfs-volants équipés de LED en musique au coucher du soleil.",
                  durationMinutes: 45, capacity: 100,
                  sessions: [.init(day: 0, hour: 18, minute: 0),
                             .init(day: 2, hour: 18, minute: 0)]),
            .init(name: "Vol libre encadré",
                  description: "Un espace dédié sur la plage pour faire voler ton propre cerf-volant avec des bénévoles pour t'aider.",
                  durationMinutes: 120, capacity: 40,
                  sessions: [.init(day: 1, hour: 13, minute: 0)])
        ]),
        .init(name: "Pilotage Acrobatique", workshops: [
            .init(name: "Premiers pas en cerf-volant pilotable",
                  description: "Découverte du deux-lignes : décollage, virages, atterrissage. Matériel fourni.",
                  durationMinutes: 60, capacity: 8,
                  sessions: [.init(day: 0, hour: 11, minute: 0, isFull: true),
                             .init(day: 1, hour: 16, minute: 0)]),
            .init(name: "Figures acrobatiques : axel et yo-yo",
                  description: "Pour pilotes ayant déjà les bases. Travail des figures freestyle avec un moniteur.",
                  durationMinutes: 90, capacity: 6,
                  sessions: [.init(day: 1, hour: 10, minute: 0, isFull: true)]),
            .init(name: "Vol en équipe synchronisé",
                  description: "Apprends à voler à plusieurs en formation, comme les équipes de compétition.",
                  durationMinutes: 90, capacity: 6,
                  sessions: [.init(day: 2, hour: 10, minute: 30)]),
            .init(name: "Initiation au quatre-lignes",
                  description: "Le cerf-volant qui fait du surplace et recule : découverte du Revolution avec un instructeur.",
                  durationMinutes: 60, capacity: 6,
                  sessions: [.init(day: 2, hour: 11, minute: 30)])
        ]),
        .init(name: "Atelier Scientifique & Vent", workshops: [
            .init(name: "Pourquoi ça vole ? L'aérodynamique expliquée",
                  description: "Portance, traînée, angle d'incidence : les principes physiques du vol, avec expériences en soufflerie.",
                  durationMinutes: 45, capacity: 25,
                  sessions: [.init(day: 0, hour: 16, minute: 0)]),
            .init(name: "Lire le vent et la météo",
                  description: "Échelle de Beaufort, rafales, vents thermiques : savoir choisir le bon moment et le bon cerf-volant.",
                  durationMinutes: 60, capacity: 20,
                  sessions: [.init(day: 0, hour: 10, minute: 30),
                             .init(day: 2, hour: 13, minute: 0)]),
            .init(name: "Fabrique ton anémomètre",
                  description: "Construis un petit anémomètre avec des gobelets et mesure la vitesse du vent sur le site.",
                  durationMinutes: 60, capacity: 15,
                  sessions: [.init(day: 0, hour: 15, minute: 0, isFull: true),
                             .init(day: 2, hour: 15, minute: 0)])
        ])
    ]
}
