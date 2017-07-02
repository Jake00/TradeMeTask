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
    
    func saveContextIfNeeded() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func doMappingAndSave<T>(doMapping: () throws -> T) throws -> T {
        let categories = try doMapping()
        try saveContextIfNeeded()
        return categories
    }
    
    // MARK: - Init
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Categories
    
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
            // "If this parameter ['number'] is empty, it returns a fictional category named “Root” with 
            // all the top categories included as subcategories."
            // We map all of the subcategories and return them, ignoring the root element.
            guard let id = Category.id(json: json), !id.isEmpty else {
                return try doMappingAndSave {
                    try Category.subcategories(json: json)
                        .flatMap(doMapping(json:))
                }
            }
            
            // There is no root element as a specific category was requested.
            // In this case we map the single category and return it as an array of one.
            return try doMappingAndSave {
                try doMapping(json: json)
            }
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
            ?? Category.create(in: context, number: number)
        
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
    
    // MARK: - Listings
    
    func mapListings(json: [JSON]) throws -> [Listing] {
        return try context.performAndWait { context in
            
            let listingIDs = json.flatMap(Listing.id)
            let listingRequest = Listing.fetchRequest(predicate: NSPredicate(format: "id IN %@", listingIDs))
            let existingListings = try context.fetch(listingRequest)
            
            let categoryIds = json.flatMap(Category.id)
            let categoriesRequest = Category.fetchRequest(predicate: NSPredicate(format: "number IN %@", categoryIds))
            let existingCategories = try context.fetch(categoriesRequest)
            
            return try doMappingAndSave {
                json.flatMap { json -> Listing? in
                    guard let id = Listing.id(json: json) else { return nil }
                    
                    let listing = existingListings.first { $0.id == id }
                        ?? Listing.create(in: context, id: id)
                    
                    listing.update(json: json)
                    listing.category = existingCategories.first { $0.number == listing.categoryNumber }
                    return listing
                }
            }
        }
    }
}
