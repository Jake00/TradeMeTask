//
//  ListingsViewController.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

class ListingsViewController: UIViewController, Loadable {
    
    var tableView: UITableView {
        // swiftlint:disable:next force_cast
        return super.view as! UITableView
    }
    
    var isLoading = false
    
    // MARK: - Init
    
    let dataSource: ListingsDataSource
    
    init(provider: RemoteDataProvider) {
        self.dataSource = ListingsDataSource(provider: provider)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "init(coder:) is not available. Use init(provider:) instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not available. Use init(provider:) instead.")
    }
    
    // MARK: - View controller
    
    override func loadView() {
        let tableView = UITableView()
        self.view = tableView
        tableView.rowHeight = 100
        tableView.backgroundColor = .offWhite
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.separatorInset.left = 0
        tableView.register(LoadingCell.self, forCellReuseIdentifier: dataSource.loadingCellIdentifier)
        tableView.register(ListingCell.self, forCellReuseIdentifier: dataSource.listingCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.listings.isEmpty {
            dataSource.fetchListings(updating: tableView)
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    // MARK: - Navigation
    
    /*
     This functionality should be delegated out so that the ListingsVC can be configured
     to not only to show the ListedItemDetailVC when a row is tapped, but is not for the 
     sake of not making this simple sample project too unwieldy.
     */
    func presentListedItemDetailViewController(listing: Listing) {
        let detailViewController = ListedItemDetailViewController(
            provider: dataSource.provider,
            listedItemId: listing.id)
        
        show(detailViewController, sender: nil)
    }
}

// MARK: - Table view delegate

extension ListingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return dataSource.listing(at: indexPath) != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let listing = dataSource.listing(at: indexPath) {
            presentListedItemDetailViewController(listing: listing)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Data source delegate

extension CategoriesViewController: ListingsDataSourceDelegate {
    
    func listingsDataSource(_ dataSource: ListingsDataSource, isFetchingWith task: Task<Void>) {
        fetch(task)
    }
}
