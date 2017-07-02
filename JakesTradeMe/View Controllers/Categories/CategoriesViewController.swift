//
//  CategoriesViewController.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

class CategoriesViewController: UIViewController {
    
    var tableView: UITableView {
        // swiftlint:disable:next force_cast
        return super.view as! UITableView
    }
    
    // MARK: - Init
    
    let dataSource: CategoriesDataSource
    
    init(provider: RemoteDataProvider) {
        self.dataSource = CategoriesDataSource(provider: provider)
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
    }
}

// MARK: - Table view delegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - Data source delegate

extension CategoriesViewController: CategoriesDataSourceDelegate {
    
    func categoriesDataSource(
        _ categoriesDataSource: CategoriesDataSource,
        isFetchingWith task: Task<Void>
        ) {
        
    }
}
