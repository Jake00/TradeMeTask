//
//  APIClient+Endpoints.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import BoltsSwift
import CoreData.NSManagedObject

extension APIClient {
    
    private func moveToViewContext<T: NSManagedObject>(_ models: [T]) -> [T] {
        return viewContext.performAndWaitWithResult { context in
            // swiftlint:disable:next force_cast
            models.map { context.object(with: $0.objectID) as! T }
        }
    }
    
    /**
     Requests the master list of categories, or if `number` is nil, a specific category.
     
     - parameter number: The ID of a specific category to fetch. Pass nil to fetch all categories.
     
     - seealso:
     [Retrieve general categories]
     (https://developer.trademe.co.nz/api-reference/catalogue-methods/retrieve-general-categories/)
     */
    func getCategories(number: String? = nil) -> Task<[Category]> {
        let request = Request(.get, "Categories/\(number ?? "0").json")
        return sendJSONRequest(request)
            .continueOnSuccessWith(.immediate, continuation: mapper.mapCategories)
            .continueOnSuccessWith(.mainThread, continuation: moveToViewContext)
    }
}
