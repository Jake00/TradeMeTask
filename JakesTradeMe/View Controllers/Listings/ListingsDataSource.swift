//
//  ListingsDataSource.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

protocol ListingsDataSourceDelegate: class {
    func listingsDataSource(_ dataSource: ListingsDataSource, isFetchingWith task: Task<Void>)
}

class ListingsDataSource: NSObject {
    
    var listings: [Listing] = []
    var searchParameters = SearchParameters()
    
    weak var delegate: ListingsDataSourceDelegate?
    
    fileprivate var hasLoadedOnce = false
    
    let listingCellIdentifier = "ListingCell"
    let loadingCellIdentifier = "LoadingCell"
    
    func listing(at indexPath: IndexPath) -> Listing? {
        return indexPath.row < listings.endIndex ? listings[indexPath.row] : nil
    }
    
    // MARK: - Init
    
    let provider: RemoteDataProvider
    
    init(provider: RemoteDataProvider) {
        self.provider = provider
        super.init()
    }
    
    // MARK: - Fetching
    
    func fetchListings(updating tableView: UITableView?) {
        let task = provider.searchListings(using: searchParameters)
            .continueOnSuccessWith(.mainThread) { result in
                self.hasLoadedOnce = true
                let isFirst = self.listings.isEmpty
                self.listings = result.listings
                if isFirst, !result.listings.isEmpty {
                    let indexPaths = (0..<result.listings.endIndex)
                        .map { IndexPath(row: $0, section: 0) }
                    tableView?.beginUpdates()
                    tableView?.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    tableView?.insertRows(at: indexPaths, with: .fade)
                    tableView?.endUpdates()
                } else {
                    tableView?.reloadData()
                }
        }
        delegate?.listingsDataSource(self, isFetchingWith: task.asVoid())
    }
}

// MARK: - Table view data source

extension ListingsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, listings.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !listings.isEmpty else {
            // swiftlint:disable:next force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellIdentifier, for: indexPath) as! LoadingCell
            let noResultsText = NSLocalizedString("listings.no_listings",
                                                  value: "No listings",
                                                  comment: "No listings for category")
            cell.titleLabel.text = hasLoadedOnce ? noResultsText : cell.loadingText
            (hasLoadedOnce ? cell.activityIndicator.stopAnimating : cell.activityIndicator.startAnimating)()
            return cell
        }
        
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: listingCellIdentifier, for: indexPath) as! ListingCell
        let listing = self.listing(at: indexPath)
        cell.titleLabel.text = listing?.title
        cell.previewImageView.setImage(url: listing?.imageURL, placeholder: #imageLiteral(resourceName: "listingPlaceholder"))
        return cell
    }
}
