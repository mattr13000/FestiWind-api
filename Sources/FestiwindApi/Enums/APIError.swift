//
//  APIError.swift
//  FestiwindApi
//
//  Created by Apprenant 77 on 16/10/2026.
//

import Foundation

enum APIError: LocalizedError {
    case emptyName
    case endTimeGreaterThanStartTime
    case wrongEventCapacity
    case categoryNotFound
    case nameAlreadyExists
    
    var errorDescription: String? {
        switch self {
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
        }
    }
}
