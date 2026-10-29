//
//  JWTMiddleware.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 01/10/2026.
//

import Vapor
import JWT

final class JWTMiddleware: Middleware {
    func respond(
        to request: Request, chainingTo next: any Responder
    ) -> EventLoopFuture<Response> {
        
        guard let token = request.headers.bearerAuthorization?.token else {
            return request.eventLoop.future(error: Abort(.unauthorized, reason: APIError.missingToken.errorDescription))
        }

        let payload: UserPayload

        do {
            payload = try request.jwt.verify(token, as: UserPayload.self)
        } catch {
            return request.eventLoop.future(error: Abort(.unauthorized, reason: APIError.invalidToken.errorDescription))
        }
        

        request.auth.login(payload)

        return next.respond(to: request)
        
    }
}
