//
//  APIError.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 16/10/2026.
//

import Foundation

enum APIError: LocalizedError {
    case badRequest
    case emptyName
    case endTimeGreaterThanStartTime
    case wrongEventCapacity
    case categoryNotFound
    case nameAlreadyExists
    case invalidCredentials
    case missingToken
    case invalidToken
    case forbidden
    case userNotFound
    case alreadyBooked
    case workshopFull

    var errorDescription: String? {
        switch self {
            case .badRequest:
                return "Bad request"
            case .emptyName:
                return "Name is empty"
            case .endTimeGreaterThanStartTime:
                return "Event ending before start time"
            case .wrongEventCapacity:
                return "Event capacity <= 0"
            case .categoryNotFound:
                return "Category not found"
            case .nameAlreadyExists:
                return "A workshop with this name already exists"
            case .invalidCredentials:
                return "Invalid email or password"
            case .missingToken:
                return "Missing token"
            case .invalidToken:
                return "Invalid or expired token"
            case .forbidden:
                return "You don't have permission to do this"
            case .userNotFound:
                return "User not found"
            case .alreadyBooked:
                return "You already booked this workshop"
            case .workshopFull:
                return "This workshop is full"
        }
    }
}
