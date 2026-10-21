//
//  UserController.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 25/09/2026.
//


import Fluent
import Vapor
import JWT
import FluentSQL

struct UserController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        users.post("login", use: login)

        let authenticated = users.grouped(JWTMiddleware())
        authenticated.get("profile", use: profile)

        let staff = authenticated.grouped(RoleMiddleware(allowedRoles: [.staff]))
        staff.get(use: index)
        staff.group(":userID") { user in
            user.get(use: getUserById)
            user.patch("role", use: updateRole)
        }
    }


    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { try $0.toDTO() }
    }


    func create(req: Request) async throws -> UserDTO {
        let newUser = try req.content.decode(CreateUserDTO.self)
        let passwordHash = try Bcrypt.hash(newUser.password)
        let userToSave = newUser.toModel(passwordHash: passwordHash)
        try await userToSave.save(on: req.db)
        return try userToSave.toDTO()
    }


    func login(req: Request) async throws -> AuthDTO {
        let userRequest = try req.content.decode(LoginDTO.self)

        guard let userDB = try await User.query(on: req.db)
            .filter(\.$email == userRequest.email)
            .first()
        else {
            throw Abort(.unauthorized, reason: APIError.invalidCredentials.errorDescription)
        }

        guard try Bcrypt.verify(userRequest.password, created: userDB.passwordHash)
        else {
            throw Abort(.unauthorized, reason: APIError.invalidCredentials.errorDescription)
        }

        let payload = UserPayload(id: try userDB.requireID(), role: userDB.role)
        let jwToken = try req.jwt.sign(payload)

        return AuthDTO(token: jwToken)
    }

    func profile(req: Request) async throws -> UserDTO {

        let payload = try req.auth.require(UserPayload.self)

        guard let userDB = try await User.find(payload.id, on: req.db)
        else {
            throw Abort(.notFound, reason: APIError.userNotFound.errorDescription)
        }

        return try userDB.toDTO()
    }

    func getUserById(req: Request) async throws -> UserDTO {
        guard let userIdReq = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing user ID.")
        }

        guard let user = try await User.find(userIdReq, on: req.db) else {
            throw Abort(.notFound, reason: APIError.userNotFound.errorDescription)
        }

        return try user.toDTO()
    }

    func updateRole(req: Request) async throws -> UserDTO {
        guard let userIdReq = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing user ID.")
        }

        let payload = try req.auth.require(UserPayload.self)
        guard payload.id != userIdReq else {
            throw Abort(.forbidden, reason: APIError.cannotChangeOwnRole.errorDescription)
        }

        let dto = try req.content.decode(UpdateRoleDTO.self)

        guard let user = try await User.find(userIdReq, on: req.db) else {
            throw Abort(.notFound, reason: APIError.userNotFound.errorDescription)
        }

        user.role = dto.role
        try await user.update(on: req.db)
        return try user.toDTO()
    }
}
