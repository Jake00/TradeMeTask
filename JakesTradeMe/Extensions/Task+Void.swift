//
//  Task+Void.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import BoltsSwift

extension Task {
    
    func asVoid() -> Task<Void> {
        return continueOnSuccessWith(.immediate) { _ in }
    }
}
