
@testable import FestiwindApi

import VaporTesting
import Testing
import Fluent
import JWT


@Suite("JWT Middleware Tests", .serialized)
struct JWTMiddlewareTests {
    
    //Configuration de l'environnement de test
    // Initialise Vapor, prépare la base de test et nettoie
    // les données après chaque scénario.
    private func withApp(
        _ test: (Application) async throws -> Void
    ) async throws {

        let app = try await Application.make(.testing)

        do {
            try await configure(app)
            try await app.autoMigrate()

            try await test(app)

            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }

    // Accès sans token JWT
    // Un utilisateur tente d'accéder à son profil
    // sans fournir de token dans l'en-tête Authorization.
    //
    // Résultat attendu : HTTP 401 Unauthorized.
    @Test("GET /users/profile - Without JWT")
    func testAccessWithoutToken() async throws {

        try await withApp { app in

            try await app.testing().test(
                .GET,
                "users/profile",
                afterResponse: { res async in

                    #expect(res.status == .unauthorized)

                }
            )
        }
    }
    
    // Accès avec un token JWT invalide
    // Un utilisateur tente d'accéder à son profil
    // avec un token JWT incorrect dans l'en-tête Authorization.
    //
    // Résultat attendu : HTTP 401 Unauthorized.

    @Test("GET /users/profile - Refuse un token JWT invalide")
    func testAccessWithInvalidToken() async throws {

        try await withApp { app in

            // Envoie une requête avec un faux token JWT
            try await app.testing().test(
                .GET,
                "users/profile",
                beforeRequest: { req in

                    req.headers.bearerAuthorization = BearerAuthorization(
                        token: "invalid.jwt.token"
                    )

                },
                afterResponse: { res async in

                    // Vérifie que l'API refuse l'accès (401)
                    #expect(res.status == .unauthorized)

                }
            )
        }
    }
    
    // Accès avec un JWT expiré
    // Un utilisateur tente d'accéder à son profil
    // avec un JWT correctement signé, mais dont la date
    // d'expiration est dépassée.
    //
    // Résultat attendu : HTTP 401 Unauthorized.

    @Test("GET /users/profile - Refuse un token JWT expiré")
    func testAccessWithExpiredToken() async throws {

        try await withApp { app in

            // Crée un utilisateur de test
            let user = try await app.createUser(
                email: "expired@test.com"
            )

            // Génère un payload JWT pour cet utilisateur
            var payload = UserPayload(
                id: try user.requireID(),
                role: user.role
            )

            // Définit une expiration une heure dans le passé
            payload.expiration = Date().addingTimeInterval(-3600)

            // Signe le JWT avec la clé utilisée par l'application
            let signer = JWTSigner.hs256(
                key: "stringmaisadressmailaussiazertyavecselpoivresaladtomatogno"
            )

            let expiredToken = try signer.sign(payload)

            // Envoie une requête avec le JWT expiré
            try await app.testing().test(
                .GET,
                "users/profile",
                beforeRequest: { req in

                    req.headers.bearerAuthorization = BearerAuthorization(
                        token: expiredToken
                    )

                },
                afterResponse: { res async in

                    // Vérifie que l'API refuse le JWT expiré
                    #expect(res.status == .unauthorized)

                }
            )
        }
    }
    
    
    
    // Accès avec un JWT valide
    // Un utilisateur authentifié accède à son profil
    // avec un token JWT valide dans l'en-tête Authorization.
    //
    // Résultat attendu : HTTP 200 OK.

    @Test("GET /users/profile - Autorise l'accès avec un JWT valide")
    func testAccessWithValidToken() async throws {

        try await withApp { app in

            // Crée un utilisateur dans la base de test
            let user = try await app.createUser(
                email: "profile@test.com"
            )

            // Génère un JWT valide pour cet utilisateur
            let token = try app.generateToken(for: user)

            // Envoie une requête authentifiée vers le profil
            try await app.testing().test(
                .GET,
                "users/profile",
                beforeRequest: { req in

                    // Ajoute le JWT dans l'en-tête Authorization
                    req.headers.bearerAuthorization =
                        BearerAuthorization(token: token)

                },
                afterResponse: { res async in

                    // Vérifie que l'accès est autorisé (200)
                    #expect(res.status == .ok)

                }
            )
        }
    }
    
    
    
    // Accès refusé pour un rôle insuffisant
    // Un utilisateur avec le rôle festivalGoer
    // tente d'accéder à une route réservée au personnel (staff).
    //
    // Résultat attendu : HTTP 403 Forbidden.

    @Test("GET /reservations - Refuse l'accès sans le rôle staff")
    func testAccessWithInsufficientRole() async throws {

        try await withApp { app in

            // Crée un utilisateur avec le rôle festivalGoer
            let user = try await app.createUser(
                email: "festivalgoer@test.com",
                role: .festivalGoer
            )

            // Génère un JWT valide pour cet utilisateur
            let token = try app.generateToken(for: user)

            // Envoie une requête vers une route réservée au staff
            try await app.testing().test(
                .GET,
                "reservations",
                beforeRequest: { req in

                    // Ajoute le JWT dans l'en-tête Authorization
                    req.headers.bearerAuthorization =
                        BearerAuthorization(token: token)

                },
                afterResponse: { res async in

                    // Vérifie que l'accès est interdit (403)
                    #expect(res.status == .forbidden)

                }
            )
        }
    }
    
    
    
    
    // Accès autorisé pour le rôle staff
    // Un utilisateur avec le rôle staff
    // accède à une route réservée au personnel.
    //
    // Résultat attendu : HTTP 200 OK.

    @Test("GET /reservations - Autorise l'accès avec le rôle staff")
    func testAccessWithStaffRole() async throws {

        try await withApp { app in

            // Crée un utilisateur avec le rôle staff
            let user = try await app.createUser(
                email: "staff@test.com",
                role: .staff
            )

            // Génère un JWT valide pour cet utilisateur
            let token = try app.generateToken(for: user)

            // Envoie une requête vers une route réservée au staff
            try await app.testing().test(
                .GET,
                "reservations",
                beforeRequest: { req in

                    // Ajoute le JWT dans l'en-tête Authorization
                    req.headers.bearerAuthorization =
                        BearerAuthorization(token: token)

                },
                afterResponse: { res async in

                    // Vérifie que l'accès est autorisé (200)
                    #expect(res.status == .ok)

                }
            )
        }
    }
    
    
}
