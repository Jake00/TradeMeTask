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
    func categoriesDataSource(_ dataSource: CategoriesDataSource, isFetchingWith task: Task<Void>)
}

class CategoriesDataSource: NSObject {
    
    var categories: [Category] = []
    
    var selectedCategory: Category? {
        didSet {
            categories = selectedCategory?.subcategories.sorted() ?? []
        }
    }
    
    weak var delegate: CategoriesDataSourceDelegate?
    
    let categoryCellIdentifier = "CategoryCell"
    let loadingCellIdentifier = "LoadingCell"
    
    func category(at indexPath: IndexPath) -> Category? {
        return indexPath.row < categories.endIndex ? categories[indexPath.row] : nil
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
        // swiftlint:disable force_cast
        
        guard !categories.isEmpty else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: loadingCellIdentifier,
                for: indexPath) as! LoadingCell
            
            let load = selectedCategory == nil
            cell.titleLabel.text = load
                ? cell.loadingText
                : NSLocalizedString(
                    "categories.no_subcategories",
                    value: "No subcategories",
                    comment: "Cell text when there are no subcategories to display.")
            (load
                ? cell.activityIndicator.startAnimating
                : cell.activityIndicator.stopAnimating)()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: categoryCellIdentifier,
            for: indexPath)
        
        let category = self.category(at: indexPath)
        cell.textLabel?.text = category?.name
        cell.textLabel?.textColor = .darkGray
        return cell
    }
}
