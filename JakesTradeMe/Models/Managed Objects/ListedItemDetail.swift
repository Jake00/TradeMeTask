//
//  ListedItemDetail.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

// MARK: Model properties

class ListedItemDetail: NSManagedObject {
    
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
    @NSManaged var listing: Listing?
    @NSManaged var photosJSON: [JSON]
}

// MARK: - Wrappers

extension ListedItemDetail {
    
    var reserveState: ListingReserveState {
        get { return ListingReserveState(rawValue: reserveStateRaw) ?? .notApplicable }
        set { reserveStateRaw = newValue.rawValue }
    }
    
    var photos: [ListingPhoto] {
        return photosJSON.flatMap(ListingPhoto.init(json:))
    }
}

// MARK: - Object context helpers

extension ListedItemDetail {
    
    static func create(in context: NSManagedObjectContext, id: Int64) -> ListedItemDetail {
        let listing: ListedItemDetail = ListedItemDetail.create(in: context)
        listing.id = id
        return listing
    }
    
    static func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<ListedItemDetail> {
        let entityName = String(describing: ListedItemDetail.self)
        let fetchRequest: NSFetchRequest<ListedItemDetail> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

// MARK: - JSON

extension ListedItemDetail {
    
    static func id(json: JSON) -> Int64? {
        return (json["ListingId"] as? Int).map(Int64.init)
    }
    
    static func categoryId(json: JSON) -> String? {
        return json["Category"] as? String
    }
    
    func update(json: JSON) {
        title = json["Title"] as? String
        subtitle = json["Subtitle"] as? String
        categoryNumber = json["Category"] as? String
        startDate = Map.date(json["StartDate"])
        endDate = Map.date(json["EndDate"])
        startPrice = Map.decimalNumber(json["StartPrice"])
        buyNowPrice = Map.decimalNumber(json["BuyNowPrice"])
        hasBuyNow = json["HasBuyNow"] as? Bool ?? false
        isFeatured = json["IsFeatured"] as? Bool ?? false
        reserveStateRaw = (json["ReserveState"] as? Int).map(Int64.init) ?? 0
        photosJSON = json["Photos"] as? [JSON] ?? []
    }
}

// MARK: - Equatable

extension ListedItemDetail {
    
    static func == (lhs: ListedItemDetail, rhs: ListedItemDetail) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension ListedItemDetail {
    
    override var hashValue: Int {
        return id.hashValue
    }
}
