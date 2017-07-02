//
//  CategoriesDataSource.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

protocol CategoriesDataSourceDelegate: class {
    func categoriesDataSource( _ categoriesDataSource: CategoriesDataSource, isFetchingWith task: Task<Void>)
}

class CategoriesDataSource: NSObject {
    
    var categories: [Category] = []
    
    weak var delegate: CategoriesDataSourceDelegate?
    
    let categoryCellIdentifier = "CategoryCell"
    let loadingCellIdentifier = "LoadingCell"
    
    // MARK: - Init
    
    let provider: RemoteDataProvider
    
    init(provider: RemoteDataProvider) {
        self.provider = provider
    }
    
    // MARK: - Fetching
    
    func fetchCategories(updating tableView: UITableView?) {
        let task = provider.getCategories(number: nil)
            .continueOnSuccessWith(.mainThread) { categories in
                let isFirst = self.categories.isEmpty
                self.categories = categories
                if isFirst, !categories.isEmpty {
                    let indexPaths = (0..<categories.endIndex)
                        .map { IndexPath(row: $0, section: 0) }
                    tableView?.beginUpdates()
                    tableView?.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    tableView?.insertRows(at: indexPaths, with: .fade)
                    tableView?.endUpdates()
                } else {
                    tableView?.reloadData()
                }
        }
        delegate?.categoriesDataSource(self, isFetchingWith: task.asVoid())
    }
}

// MARK: - Table view data source

extension CategoriesDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, categories.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !categories.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: loadingCellIdentifier, for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
}
