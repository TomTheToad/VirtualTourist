//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/27/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    let coreData: CoreDataStack = {
       return AppDelegate().coreDataStack
    }()
    
    let managedObjectContext: NSManagedObjectContext = {
        let coreData = AppDelegate().coreDataStack
        return coreData.managedObjectContext
    }()
    
//    func getCoreData() -> CoreDataStack {
//        return coreData
//    }
//    
//    func getManagedObjectContext() -> NSManagedObjectContext {
//        return managedObjectContext
//    }
    
    func coreDataTest() {
    /// Begin CoreData Test ///
            let image = Image(context: managedObjectContext)
            image.id = "testImage"
    
    
            do {
                try coreData.saveMainContext()
            } catch {
                print("WARNING: Core Data did not save")
            }
    /// End CoreData Test ///
    }
}
