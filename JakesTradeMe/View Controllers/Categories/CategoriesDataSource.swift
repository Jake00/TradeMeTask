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
    
    struct Cells {
        static let category = "CategoryCell"
    }
    
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
                    tableView?.insertRows(at: indexPaths, with: .fade)
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
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.category, for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
}
