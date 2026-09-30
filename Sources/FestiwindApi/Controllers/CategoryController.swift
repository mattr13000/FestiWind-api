//
//  CategoryController.swift
//  FestiwindApi
//
//  Created by Apprenant 87 on 29/09/2026.
//

import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        
        let categories = routes.grouped("categories")
        
        categories.get(use: index)
        categories.post(use: create)
        
        categories.group(":id") { category in
            category.put(use: update)
            category.delete(use: delete)
        }

    }
    
    func index(req: Request) async throws -> [CategoryDTO] {

        let categories = try await Category.query(on: req.db).all()

        
        return try categories.map { try $0.updateDTO() }
        //        équivalent : return categories.map { category in CategoryDTO(id: category.id, name: category.name) }
        
    }
    
    func create(req: Request) async throws -> Category {

        let dto = try req.content.decode(CategoryDTO.self)
        
        guard !dto.name.isEmpty else {
            throw Abort(.badRequest, reason: "la catégorie est obligatoire.")
        }
        
        let category = dto.toModel()
        
        try await category.create(on: req.db)
        return category
    }
    
    func update(req: Request) async throws -> CategoryDTO {
        

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant invalide.")
        }

        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Catégorie introuvable.")
        }

        var newCategory = try req.content.decode(CategoryDTO.self)

        guard !newCategory.name.isEmpty else {
            throw Abort(.badRequest, reason: "Catégorie est obligatoire.")
        }
        
        category.name = newCategory.name

        try await category.update(on: req.db)
        return try category.updateDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant invalide.")
        }

        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Catégorie introuvable.")
        }

        try await category.delete(on: req.db)
        return .noContent
    }
}
