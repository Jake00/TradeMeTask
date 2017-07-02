//
//  CategoriesViewController.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

class CategoriesViewController: UIViewController, Loadable {
    
    var tableView: UITableView {
        // swiftlint:disable:next force_cast
        return super.view as! UITableView
    }
    
    var isLoading = false
    
    // MARK: - Init
    
    let dataSource: CategoriesDataSource
    
    init(provider: RemoteDataProvider) {
        self.dataSource = CategoriesDataSource(provider: provider)
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("categories_title",
                                       value: "Categories",
                                       comment: "Title of the categories screen")
    }
    
    @available(*, unavailable, message: "init(coder:) is not available. Use init(provider:) instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not available. Use init(provider:) instead.")
    }
    
    // MARK: - View controller
    
    override func loadView() {
        let tableView = UITableView()
        self.view = tableView
        tableView.backgroundColor = .offWhite
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(LoadingCell.self, forCellReuseIdentifier: dataSource.loadingCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: dataSource.categoryCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.categories.isEmpty {
            dataSource.fetchCategories(updating: tableView)
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    // MARK: - Navigation
    
    /* 
     This functionality should be delegated out so that the CategoryVC can be configured
     to not only to show the ListingsVC when a row is tapped, but is not for the sake of
     not making this simple sample project too unwieldy.
     */
    func presentListingsViewController(category: Category?) {
        let listingsViewController = ListingsViewController(provider: dataSource.provider)
        listingsViewController.dataSource.searchParameters.categoryNumber = category?.number
        
        let titleFormat = NSLocalizedString("listings.title_format",
                                            value: "Listings for %@",
                                            comment: "The title format for listings in a category. eg. 'Listings for Art'")
        listingsViewController.title = String.localizedStringWithFormat(titleFormat, category?.name ?? "")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [listingsViewController]
        showDetailViewController(navigationController, sender: nil)
    }
}

// MARK: - Table view delegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return dataSource.category(at: indexPath) != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentListingsViewController(category: dataSource.category(at: indexPath))
    }
}

// MARK: - Data source delegate

extension CategoriesViewController: CategoriesDataSourceDelegate {
    
    func categoriesDataSource(_ dataSource: CategoriesDataSource, isFetchingWith task: Task<Void>) {
        fetch(task)
    }
}
