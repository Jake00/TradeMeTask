//
//  URLParameterEncodable.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation

protocol URLParameterEncodable {
    var description: String { get }
}

// These types may be URL encoded in a request. 

extension String: URLParameterEncodable { }
extension Int: URLParameterEncodable { }
extension Double: URLParameterEncodable { }
