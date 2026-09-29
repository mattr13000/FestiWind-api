//
//  CategoryToDTO.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 29/09/2026.
//
import Vapor
import Fluent

extension Category {
    func createDTO() throws -> CreateCategoryDTO {
                return CreateCategoryDTO(
                    name: name
                )
    }
}

extension Category {
    func updateDTO() throws -> UpdateCategoryDTO {
        return UpdateCategoryDTO(
            id: try requireID(),
            name: name
        )
    }
}
