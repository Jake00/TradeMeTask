//
//  SearchParameters.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

struct SearchParameters {
    
    var categoryNumber: String?
    var resultsPerPage: Int
    
    init(categoryNumber: String? = nil, resultsPerPage: Int = 20) {
        self.categoryNumber = categoryNumber
        self.resultsPerPage = resultsPerPage
    }
}

// MARK: - Equatable

extension SearchParameters {
    
    static func == (lhs: SearchParameters, rhs: SearchParameters) -> Bool {
        return lhs.categoryNumber == rhs.categoryNumber
    }
}
