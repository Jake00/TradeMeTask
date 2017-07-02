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
    
    // Loaded in `loadView()`.
    private(set) var tableView: UITableView!
    private(set) var headerView: UIView!
    private(set) var headerLabel: UILabel!
    private(set) var showListingsButton: UIBarButtonItem!
    
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
        view = UIView()
        setupTableView()
        setupHeaderView()
        setupShowListingsButton()
        
        // Hide back navigation button title
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.selectedCategory == nil, dataSource.categories.isEmpty {
            dataSource.fetchCategories(updating: tableView)
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    private var isFirstLayout = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.top = headerView.frame.maxY
        tableView.scrollIndicatorInsets.top = headerView.frame.maxY
        if isFirstLayout {
            isFirstLayout = false
            tableView.contentOffset.y = -tableView.contentInset.top
        }
    }
    
    // MARK: - Subviews init
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .offWhite
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(LoadingCell.self, forCellReuseIdentifier: dataSource.loadingCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: dataSource.categoryCellIdentifier)
        view.addSubview(tableView)
    }
    
    private func setupHeaderView() {
        let toolbar = UIToolbar()
        toolbar.delegate = self
        headerView = toolbar
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = .darkGray
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        let separator = NSLocalizedString("categories.path_joiner",
                                          value: " > ",
                                          comment: "The separator between category levels.")
        headerLabel.text = dataSource.selectedCategory?.pathComponents.joined(separator: separator)
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        let margin = headerView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: margin.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: margin.bottomAnchor)
            ])
    }
    
    private func setupShowListingsButton() {
        let showListingsTitle = NSLocalizedString(
            "categories.show_listings",
            value: "Show listings",
            comment: "Button title for showing listings for the selected category")
        showListingsButton = UIBarButtonItem(
            title: showListingsTitle,
            style: .plain,
            target: self,
            action: #selector(showListingsButtonPressed(_:)))
        navigationItem.rightBarButtonItem = showListingsButton
        showListingsButton.isEnabled = dataSource.selectedCategory?.pathComponents.isEmpty == false
    }
    
    // MARK: - Interface actions
    
    func showListingsButtonPressed(_ sender: UIBarButtonItem) {
        presentListingsViewController(category: dataSource.selectedCategory)
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
        
        let titleFormat = NSLocalizedString(
            "listings.title_format",
            value: "Listings for %@",
            comment: "The title format for listings in a category. eg. 'Listings for Art'")
        listingsViewController.title = String.localizedStringWithFormat(titleFormat, category?.name ?? "")
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [listingsViewController]
        showDetailViewController(navigationController, sender: nil)
    }
    
    func presentNextCategoriesViewController(category: Category) {
        let categoriesViewController = CategoriesViewController(provider: dataSource.provider)
        categoriesViewController.dataSource.selectedCategory = category
        show(categoriesViewController, sender: nil)
    }
}

// MARK: - Table view delegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return dataSource.category(at: indexPath) != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let category = dataSource.category(at: indexPath) {
            presentNextCategoriesViewController(category: category)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Data source delegate

extension CategoriesViewController: CategoriesDataSourceDelegate {
    
    func categoriesDataSource(_ dataSource: CategoriesDataSource, isFetchingWith task: Task<Void>) {
        fetch(task)
    }
}

// MARK: - Toolbar delegate

extension CategoriesViewController: UIToolbarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
}
