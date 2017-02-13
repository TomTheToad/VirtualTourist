//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/13/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    
    // Fields
    static let moduleName = "VirtualTourist"
    
    
    // Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    // Helper to access documents directory for app
    lazy var applicationDocumentDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    
    // Persistent Store Coordinator
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentDirectory.appendingPathComponent("\(moduleName).sqlite")
        
        // Attempt to add a persistend store to the coordinator
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store error! \(error)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    
    /* Methods */
    // todo: dispatch to custom synch queue?
    func saveMainContext() throws {
        if managedObjectContext.hasChanges {
                try managedObjectContext.save()
        }
    }
}
