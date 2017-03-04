//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/27/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

class CoreDataController {
    
    // Fields
    let appDelegate = AppDelegate()
    
    func coreDataTest() {
    /// Begin CoreData Test ///
            let coreData = appDelegate.coreDataStack
            let managedObjectContext = coreData.managedObjectContext
    
    
            let image = Image(context: managedObjectContext)
            image.title = "TestImage"
    
    
            do {
                try coreData.saveMainContext()
            } catch {
                print("WARNING: Core Data did not save")
            }
    /// End CoreData Test ///
    }
}
