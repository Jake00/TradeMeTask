//
//  CoreDataClient.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import CoreData

final class CoreDataClient {
    
    static let managedObjectModel: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "JakesTradeMe", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        return NSManagedObjectModel(contentsOf: url) ?? {
            fatalError("Error initializing managed object model from: \(url)")
        }()
    }()
    
    let viewContext: NSManagedObjectContext
    let jsonContext: NSManagedObjectContext
    
    init() {
        let model = CoreDataClient.managedObjectModel
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        do {
            try coordinator.addPersistentStore(
                ofType: NSInMemoryStoreType,
                configurationName: nil,
                at: nil,
                options: nil)
        } catch {
            // Migrations for the store is out of scope as no data is persisted
            // between launches due to store type being 'in memory' only.
            fatalError("Error migrating store: \(error)")
        }
        
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        jsonContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        for context in [viewContext, jsonContext] {
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            context.persistentStoreCoordinator = coordinator
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(contextDidSave(_:)),
                name: .NSManagedObjectContextDidSave,
                object: context)
        }
    }
    
    private var savingContext: NSManagedObjectContext?
    
    private dynamic func contextDidSave(_ notification: Notification) {
        guard let object = notification.object as? NSManagedObjectContext,
            object == viewContext || object == jsonContext,
            savingContext == nil
            else { return }
        
        let otherContext = object == jsonContext ? viewContext : jsonContext
        otherContext.performAndWait {
            self.savingContext = otherContext
            otherContext.mergeChanges(fromContextDidSave: notification)
            if otherContext.hasChanges {
                do {
                    try otherContext.save()
                } catch {
                    print("Error saving context: \(otherContext): \(error)")
                }
            }
            self.savingContext = nil
        }
    }
}
