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
    var modelURL: URL {
        get{
            return Bundle.main.url(forResource: CoreDataStack.moduleName, withExtension: "momd")!
        }
    }
    
    let fileManager = FileManager.default
    
    var docURL: URL {
        get{
            return self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    
    var dbURL: URL {
        get {
        
        return self.docURL.appendingPathComponent("model.sqlite")
        }
    }
    
    
    // Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = self.modelURL
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
    
    init() {
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    /* Utility Methods */
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
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
    
    
    /* Methods */
    // todo: dispatch to custom synch queue?
    func saveMainContext() throws {
        if managedObjectContext.hasChanges {
                try managedObjectContext.save()
        }
    }
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try persistentStoreCoordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}
