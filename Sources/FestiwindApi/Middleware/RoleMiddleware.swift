//
//  RoleMiddleware.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 21/10/2026.
//

import Vapor

final class RoleMiddleware: Middleware {
    let allowedRoles: [UserRole]

    init(allowedRoles: [UserRole]) {
        self.allowedRoles = allowedRoles
    }

    func respond(
        to request: Request, chainingTo next: any Responder
    ) -> EventLoopFuture<Response> {

        guard let payload = request.auth.get(UserPayload.self) else {
            return request.eventLoop.future(error: Abort(.unauthorized, reason: APIError.missingToken.errorDescription))
        }

        guard allowedRoles.contains(payload.role) else {
            return request.eventLoop.future(error: Abort(.forbidden, reason: APIError.forbidden.errorDescription))
        }

        return next.respond(to: request)
    }
}
