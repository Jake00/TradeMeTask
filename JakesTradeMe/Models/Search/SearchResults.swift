//
//  SearchResults.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

struct SearchResults {
    
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let listings: [Listing]
    
    init(json: JSON, listings: [Listing]) {
        self.totalCount = json["TotalCount"] as? Int ?? 0
        self.page = json["Page"] as? Int ?? 1
        self.pageSize = json["PageSize"] as? Int ?? 0
        self.listings = listings
    }
    
    static func listings(json: JSON) -> [JSON] {
        return json["List"] as? [JSON] ?? []
    }
}
