//
//  UserPayload.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 01/10/2026.
//

import Foundation
import Vapor
import JWT

struct UserPayload: JWTPayload, Authenticatable {
    var id: UUID
    var expiration: Date
    
    init(id: UUID) {
        self.id = id
        expiration = Date().addingTimeInterval(3600 * 240)
    }
    
    func verify(using signer: JWTSigner) throws {
        if expiration < Date() {
            throw JWTError.invalidJWK
        }
    }
}
