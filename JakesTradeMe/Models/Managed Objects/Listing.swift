//
//  Listing.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

// MARK: Model properties

class Listing: NSManagedObject {
    
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var subtitle: String?
    @NSManaged var imageURLRaw: String?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var startPrice: NSDecimalNumber?
    @NSManaged var buyNowPrice: NSDecimalNumber?
    @NSManaged var categoryNumber: String?
    @NSManaged var category: Category?
    @NSManaged var hasBuyNow: Bool
    @NSManaged var isFeatured: Bool
    @NSManaged var reserveStateRaw: Int64
}

// MARK: - Reserve state

extension Listing {
    
    enum ReserveState: Int64 {
        case none
        case met
        case notMet
        case notApplicable
    }
    
    var reserveState: ReserveState {
        get { return ReserveState(rawValue: reserveStateRaw) ?? .notApplicable }
        set { reserveStateRaw = newValue.rawValue }
    }
}

// MARK: - Image URL

extension Listing {
    
    var imageURL: URL? {
        get { return imageURLRaw.flatMap(URL.init(string:)) }
        set { imageURLRaw = newValue?.absoluteString }
    }
}

// MARK: - Object context helpers

extension Listing {
    
    static func create(in context: NSManagedObjectContext, id: Int64) -> Listing {
        let listing: Listing = Listing.create(in: context)
        listing.id = id
        return listing
    }
    
    static func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Listing> {
        let fetchRequest: NSFetchRequest<Listing> = NSFetchRequest(entityName: String(describing: Listing.self))
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

// MARK: - JSON

extension Listing {
    
    static func id(json: JSON) -> Int64? {
        return (json["ListingId"] as? Int).map(Int64.init)
    }
    
    func update(json: JSON) {
        title = json["Title"] as? String
        subtitle = json["Subtitle"] as? String
        categoryNumber = json["Category"] as? String
        imageURLRaw = json["PictureHref"] as? String
        startDate = date(json["StartDate"])
        endDate = date(json["EndDate"])
        startPrice = decimalNumber(json["StartPrice"])
        buyNowPrice = decimalNumber(json["BuyNowPrice"])
        hasBuyNow = json["HasBuyNow"] as? Bool ?? false
        isFeatured = json["IsFeatured"] as? Bool ?? false
        reserveStateRaw = (json["ReserveState"] as? Int).map(Int64.init) ?? 0
    }
    
    private func decimalNumber(_ value: Any?) -> NSDecimalNumber? {
        return (value as? NSNumber)
            .map { NSDecimalNumber(decimal: $0.decimalValue) }
    }
    
    private func date(_ value: Any?) -> Date? {
        guard var characters = (value as? String)?.characters,
            characters.count >= 8 else { return nil }
        characters.removeFirst(6)
        characters.removeLast(2)
        return TimeInterval(String(characters))
            .map(Date.init(timeIntervalSince1970:))
    }
}
