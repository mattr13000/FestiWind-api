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
    
    func index(req: Request) async throws -> [Category] {
        return try await Category
            .query(on: req.db)
            .all()
    }
    
    func create(req: Request) async throws -> Category {

//        let dto = try req.content.decode(CreateCategoryDTO.self)
        let category = try req.content.decode(Category.self)
        
//        struct CreateCategoryDTO: Content {
//            var name: String
//        }
        

        guard !category.name.isEmpty else {
            throw Abort(.badRequest, reason: "la catégorie est obligatoire.")
        }
//    let category = Category(name: dto.name)

        try await category.create(on: req.db)
        return category
    }
    
    func update(req: Request) async throws -> Category {

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant invalide.")
        }

        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Auteur introuvable.")
        }

        let newCategory = try req.content.decode(Category.self)

        guard !newCategory.name.isEmpty else {
            throw Abort(.badRequest, reason: "L'auteur est obligatoire.")
        }

        category.name = newCategory.name

        try await category.update(on: req.db)
        return category
    }

    func delete(req: Request) async throws -> HTTPStatus {

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant invalide.")
        }

        guard let category = try await Category.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Auteur introuvable.")
        }

        try await category.delete(on: req.db)
        return .noContent
    }
}
