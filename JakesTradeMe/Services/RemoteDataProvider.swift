//
//  RemoteDataProvider.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import BoltsSwift

/**
 Matches the endpoints provided by `APIClient`, allowing testing via swapping
 in another object which serves pre-saved responses without hitting the network.
 */
protocol RemoteDataProvider {
    func getCategories(number: String?) -> Task<[Category]>
    func searchListings(using search: SearchParameters) -> Task<SearchResults>
    func getListedItem(id: Int64) -> Task<ListedItemDetail>
}
