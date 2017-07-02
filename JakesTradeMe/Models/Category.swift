//
//  Category.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

// MARK: Model properties

class Category: NSManagedObject {
    
    @NSManaged var name: String?
    @NSManaged var number: String
    @NSManaged var numberId: Int64
    @NSManaged var path: String?
    @NSManaged var count: Int64
    @NSManaged var areaOfBusinessRaw: Int64
    @NSManaged var canBeSecondCategory: Bool
    @NSManaged var canHaveSecondCategory: Bool
    @NSManaged var hasClassifieds: Bool
    @NSManaged var hasLegalNotice: Bool
    @NSManaged var isRestricted: Bool
    @NSManaged var parent: Category?
    @NSManaged var subcategories: Set<Category>
}

// MARK: - Area of business

extension Category {
    
    enum AreaOfBusiness: Int64 {
        case unspecified
        case marketplace
        case property
        case motors
        case jobs
        case services
        
        static var all: AreaOfBusiness {
            return .unspecified
        }
    }
    
    var areaOfBusiness: AreaOfBusiness {
        get { return AreaOfBusiness(rawValue: areaOfBusinessRaw) ?? .unspecified }
        set { areaOfBusinessRaw = newValue.rawValue }
    }
}

// MARK: - Object context helpers

extension Category {
    
    static func create(in context: NSManagedObjectContext, id: String) -> Category {
        let category: Category = Category.create(in: context)
        category.number = id
        return category
    }
    
    static func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Category> {
        let fetchRequest: NSFetchRequest<Category> = NSFetchRequest(entityName: String(describing: Category.self))
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

// MARK: - JSON

extension Category {
    
    static func id(json: JSON) -> String? {
        // The ID for a category is changing:
        // https://developer.trademe.co.nz/api-reference/catalogue-methods/retrieve-general-categories/
        // "We plan to change this to a numeric identifier (e.g. “6076”) so you should ensure you can cope with both formats."
        guard let id = json["Number"] else { return nil }
        return id as? String ?? (id as? Int).map(String.init)
    }
    
    static func subcategories(json: JSON) -> [JSON] {
        return json["Subcategories"] as? [JSON] ?? []
    }
    
    func update(json: JSON) {
        name = json["Name"] as? String
        numberId = (json["Number"] as? Int).map(Int64.init) ?? 0
        path = json["Path"] as? String
        count = (json["Count"] as? Int).map(Int64.init) ?? 0
        areaOfBusinessRaw = (json["AreaOfBusiness"] as? Int).map(Int64.init) ?? 0
        canBeSecondCategory = json["CanBeSecondCategory"] as? Bool ?? false
        canHaveSecondCategory = json["CanHaveSecondCategory"] as? Bool ?? false
        hasClassifieds = json["HasClassifieds"] as? Bool ?? false
        isRestricted = json["IsRestricted"] as? Bool ?? false
        hasLegalNotice = json["HasLegalNotice"] as? Bool ?? false
    }
}
