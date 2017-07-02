//
//  NSManagedObjectContext+Perform.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    private enum Either<A, B> {
        case first(A)
        case other(B)
    }
    
    // Throwing variant
    func performAndWait<T>(_ block: (NSManagedObjectContext) throws -> T) throws -> T {
        return try withoutActuallyEscaping(block) { block in
            var value: Either<T, Error>?
            performAndWait { () -> Void in
                do {
                    value = try .first(block(self))
                } catch {
                    value = .other(error)
                }
            }
            switch value {
            case .first(let v)?: return v
            case .other(let e)?: throw e
            default: fatalError("Result was not set. This should never happen.")
            }
        }
    }
    
    // Non throwing variant
    func performAndWaitWithResult<T>(_ block: (NSManagedObjectContext) -> T) -> T {
        return withoutActuallyEscaping(block) { block in
            var value: T?
            performAndWait { () -> Void in
                value = block(self)
            }
            return value!
        }
    }
}
