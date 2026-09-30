//
//  CategoryToDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 29/09/2026.
//
import Vapor
import Fluent

extension Category {
    func createDTO() throws -> CategoryDTO {
                return CategoryDTO(
                    name: name
                )
    }
}

extension Category {
    func updateDTO() throws -> CategoryDTO {
        return CategoryDTO(
            id: try requireID(),
            name: name
        )
    }
}
