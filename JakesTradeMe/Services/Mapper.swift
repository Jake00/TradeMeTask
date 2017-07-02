//
//  Mapper.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

typealias JSON = [String: Any]

final class Mapper {
    
    // MARK: - Init
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Mapping
    
    func mapCategories(json: Any) throws -> [Category] {
        guard let json = json as? JSON else {
            throw APIClient.Errors.invalidResponse
        }
        
        return try context.performAndWait { context in
            
            func doMapping(json: JSON) throws -> [Category] {
                guard let id = Category.id(json: json), !id.isEmpty else {
                    return []
                }
                let request = Category.fetchRequest(predicate: NSPredicate(format: "number BEGINSWITH %@", id))
                let existing = try context.fetch(request)
                let category = self.mapCategory(
                    json: json,
                    parent: nil,
                    existing: existing,
                    context: context)
                return category.map { [$0] } ?? []
            }
            
            // Special case handling of top level containing 'Root' element:
            // https://developer.trademe.co.nz/api-reference/catalogue-methods/retrieve-general-categories/
            // "If this parameter ['number'] is empty, it returns a fictional category named “Root” with all the top categories included as subcategories."
            // We map all of the subcategories and return them, ignoring the root element.
            guard let id = Category.id(json: json), !id.isEmpty else {
                return try Category.subcategories(json: json)
                    .flatMap(doMapping(json:))
            }
            
            // There is no root element as a specific category was requested.
            // In this case we map the single category and return it as an array of one.
            return try doMapping(json: json)
        }
    }
    
    private func mapCategory(
        json: JSON,
        parent: Category?,
        existing: [Category],
        context: NSManagedObjectContext
        ) -> Category? {
        
        guard let number = Category.id(json: json), !number.isEmpty else {
            return nil
        }
        
        let category = existing.first { $0.number == number }
            ?? Category.create(in: context, id: number)
        
        category.update(json: json)
        
        // When specifically requesting a child element its parent categories
        // are not returned, so we don't want to nil them out here.
        if parent != nil {
            category.parent = parent
        }
        
        // Recursively map subcategories that this element may have.
        category.subcategories = Set(
            Category.subcategories(json: json).flatMap {
                mapCategory(
                    json: $0,
                    parent: category,
                    existing: existing,
                    context: context)
        })
        return category
    }
}
