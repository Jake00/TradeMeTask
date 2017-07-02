//
//  SearchParameters.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

struct SearchParameters {
    
    var categoryNumber: String?
    
    init(categoryNumber: String? = nil) {
        self.categoryNumber = categoryNumber
    }
}

// MARK: - Equatable

extension SearchParameters {
    
    static func == (lhs: SearchParameters, rhs: SearchParameters) -> Bool {
        return lhs.categoryNumber == rhs.categoryNumber
    }
}
