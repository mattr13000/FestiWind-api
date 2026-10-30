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
        let authenticated = users.grouped(JWTMiddleware())
        let staff = authenticated.grouped(RoleMiddleware(allowedRoles: [.staff]))
        
        users.post(use: create)
        users.post("login", use: login)
        authenticated.get("profile", use: profile)

        staff.get(use: index)
        staff.get(":userID", use: getUserById)
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
            throw Abort(.unauthorized, reason: "Unable to sign in to your account")
        }//we switch the error notFound to unauthorized and the error message to dont give information if the mail exist in the back.
  
        guard try Bcrypt.verify(userRequest.password, created: userDB.passwordHash)
        else {
            throw Abort(.unauthorized, reason: "Unable to sign in to your account")
        }

        let payload = UserPayload(id: try userDB.requireID(), role: userDB.role)
        let jwToken = try req.jwt.sign(payload)

        return AuthDTO(token: jwToken)
    }

    func profile(req: Request) async throws -> UserDTO {

        let payload = try req.auth.require(UserPayload.self)

        guard let user = try await User.find(payload.id, on: req.db)
        else {
            throw Abort(.notFound, reason: APIError.userNotFound.errorDescription)
        }

        return try user.toDTO()
    }

    func getUserById(req: Request) async throws -> UserDTO {
        guard let userIdReq = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: APIError.emptyName.errorDescription)
        }

        guard let user = try await User.find(userIdReq, on: req.db) else {
            throw Abort(.notFound, reason: APIError.userNotFound.errorDescription)
        }

        return try user.toDTO()
    }
}
