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
        users.get(use: index)
        users.post(use: create)
        users.post("login", use: login)

        let protectedRoutes = users.grouped(JWTMiddleware())
        protectedRoutes.get("profile", use: profile)
        
        protectedRoutes.group(":userID") { user in
            protectedRoutes.get(":userID", use: getUserById)
        }
    }
    
   
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { try $0.toDTO() }
    }
    
    
    func create(req: Request) async throws -> UserDTO {
        var newUser = try req.content.decode(CreateUserDTO.self)
        newUser.passwordHash = try Bcrypt.hash(newUser.passwordHash)
        let userToSave = newUser.toModel()
        try await userToSave.save(on: req.db)
        return try userToSave.toDTO()
    }
    
    
    func login(req: Request) async throws -> AuthDTO {
        let userRequest = try req.content.decode(LoginDTO.self)

        guard let userDB = try await User.query(on: req.db)
            .filter(\.$email == userRequest.email)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }
  
        guard try Bcrypt.verify(userRequest.password, created: userDB.passwordHash)
        else {
            throw Abort(.notFound, reason: "Wrong password.")
        }
        
        let payload = UserPayload(id: userDB.id!)
        let signer = JWTSigner.hs256(key: "stringmaisadressmailaussiazertyavecselpoivresaladtomatogno")
        let jwToken = try signer.sign(payload)
        
        return AuthDTO(token: jwToken)
    }
     
    func profile(req: Request) async throws -> UserDTO {

        let payload = try req.auth.require(UserPayload.self)

        guard let userDB = try await User.find(payload.id, on: req.db)
        else {
            throw Abort(.notFound, reason: "User not found.")
        }

        return try userDB.toDTO()
    }
    
    func getUserById(req: Request) async throws -> UserDTO {
        guard let userIdReq = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing user ID.")
        }
        
        guard let user = try await User.find(userIdReq, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        return try user.toDTO()
    }
}
