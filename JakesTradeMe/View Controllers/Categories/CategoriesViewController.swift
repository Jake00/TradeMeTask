//
//  CategoriesViewController.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    var tableView: UITableView {
        // swiftlint:disable:next force_cast
        return super.view as! UITableView
    }
    
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
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
}

// MARK: - Table view delegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
