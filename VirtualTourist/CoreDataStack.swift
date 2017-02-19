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
    // Set Module name
    static let moduleName = "VirtualTouristModel"
    
    // URL for CoreDataStack module "momd" file
    var modelURL: URL {
        get{
            return Bundle.main.url(forResource: CoreDataStack.moduleName, withExtension: "momd")!
        }
    }
    
    // URL for documents directory
    var documentDirectoryURL: URL {
        get{
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    
    // URL for SQLLite database
    var databaseURL: URL {
        get {
        
        return self.documentDirectoryURL.appendingPathComponent("model.sqlite")
        }
    }
    
    
    // Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    }()
    
    // Persistent Store Coordinator
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return coordinator
    }()
    
    // Managed Object Context
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // Initializer
    // todo: This was moved into the init method.
    // Determine if this means that unnecessary Stores are being added each time file is initialized.
    init() {
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addPersistentStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(databaseURL)")
        }
    }

    
    /* Main Methods */
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveMainContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
    

    // todo: dispatch to custom synch queue?
    func saveMainContext() throws {
        if managedObjectContext.hasChanges {
                try managedObjectContext.save()
        }
    }
    
    
    /* Utility Methods */
    func addPersistentStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
    
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try persistentStoreCoordinator.destroyPersistentStore(at: databaseURL, ofType:NSSQLiteStoreType , options: nil)
        try addPersistentStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: nil)
    }
}
