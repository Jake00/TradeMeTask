//
//  ListingsDataSource.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit

class ListingsDataSource: NSObject {
    
    var listings: [Listing] = []
    
    struct Cells {
        static let listing = "ListingCell"
    }
    
    // MARK: - Init
    
    let provider: RemoteDataProvider
    
    init(provider: RemoteDataProvider) {
        self.provider = provider
        super.init()
    }
}

// MARK: - Table view data source

extension ListingsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.listing, for: indexPath)
        let listing = listings[indexPath.row]
        cell.textLabel?.text = listing.title
        return cell
    }
}
