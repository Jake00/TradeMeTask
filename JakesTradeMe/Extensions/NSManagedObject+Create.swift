//
//  NSManagedObject+Create.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    static func create<T: NSManagedObject>(in context: NSManagedObjectContext) -> T {
        let entityName = String(describing: T.self)
        let anyModel = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        return anyModel as? T ?? {
            fatalError(
                "Managed object \(entityName) did not create as type \(T.self), "
                    + "instead it was created as \(type(of: anyModel))")
            }()
    }
}
