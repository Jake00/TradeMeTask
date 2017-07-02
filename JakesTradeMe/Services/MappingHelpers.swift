//
//  MappingHelpers.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation

struct Map {
    
    static func decimalNumber(_ value: Any?) -> NSDecimalNumber? {
        return (value as? NSNumber)
            .map { NSDecimalNumber(decimal: $0.decimalValue) }
    }
    
    static func date(_ value: Any?) -> Date? {
        guard var characters = (value as? String)?.characters,
            characters.count >= 8 else { return nil }
        characters.removeFirst(6)
        characters.removeLast(2)
        return TimeInterval(String(characters))
            .map(Date.init(timeIntervalSince1970:))
    }
}
