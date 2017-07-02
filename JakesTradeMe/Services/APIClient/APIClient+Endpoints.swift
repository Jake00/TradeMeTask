//
//  APIClient+Endpoints.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import BoltsSwift
import CoreData.NSManagedObject

extension APIClient: RemoteDataProvider {
    
    /**
     Requests either a specified category, or if `number` is nil, the master list of all categories.
     
     - parameter number: The ID of a specific category to fetch. Pass nil to fetch all categories.
     
     - seealso:
     [Retrieve general categories]
     (https://developer.trademe.co.nz/api-reference/catalogue-methods/retrieve-general-categories/)
     */
    func getCategories(number: String?) -> Task<[Category]> {
        let request = Request(.get, "Categories/\(number ?? "0").json")
        return sendJSONRequest(request)
            .continueOnSuccessWith(.immediate, continuation: mapper.mapCategories)
            .continueOnSuccessWith(.mainThread, continuation: moveAllToViewContext)
    }
    
    /**
     Requests listings using the given search parameters.
     
     - parameter search: The search parameters to include in the request.
     
     - seealso:
     [General search]
     (https://developer.trademe.co.nz/api-reference/search-methods/general-search/)
     */
    func searchListings(using search: SearchParameters) -> Task<SearchResults> {
        var parameters: Parameters = [:]
        if let category = search.categoryNumber {
            parameters["Category"] = category
        }
        let request = Request(.get, "Search/General.json", parameters: parameters)
        
        return sendJSONRequest(request)
            .continueOnSuccessWith(.immediate) { json -> (JSON, [Listing]) in
                guard let json = json as? JSON else { throw Errors.invalidResponse }
                let listingsJSON = SearchResults.listings(json: json)
                let listings = try self.mapper.mapListings(json: listingsJSON)
                return (json, listings)
            }.continueOnSuccessWith(.mainThread) { json, listings in
                let listings = self.moveAllToViewContext(listings)
                return SearchResults(json: json, listings: listings)
        }
    }
    
    /**
     Requests the details about a listed item.
     
     - parameter id: The listing id to retreive results for.
     
     - seealso:
     [Retrieve the details of a single listing]
     (https://developer.trademe.co.nz/api-reference/listing-methods/retrieve-the-details-of-a-single-listing/)
     */
    func getListedItem(id: Int64) -> Task<ListedItemDetail> {
        let request = Request(.get, "Listings/\(id).json")
        return sendJSONRequest(request)
            .continueOnSuccessWith(.immediate, continuation: mapper.mapListedItemDetail)
            .continueOnSuccessWith(.mainThread, continuation: moveToViewContext)
    }
    
    private func moveToViewContext<T: NSManagedObject>(_ model: T) -> T {
        return viewContext.performAndWaitWithResult { context in
            // swiftlint:disable:next force_cast
            context.object(with: model.objectID) as! T
        }
    }
    
    private func moveAllToViewContext<T: NSManagedObject>(_ models: [T]) -> [T] {
        return viewContext.performAndWaitWithResult { context in
            // swiftlint:disable:next force_cast
            models.map { context.object(with: $0.objectID) as! T }
        }
    }
}
