//
//  ViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/13/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Fields
    let appDelegate = AppDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        let coreData = appDelegate.coreDataStack
        let managedObjectContext = coreData.managedObjectContext
        
        
        let image = Image(context: managedObjectContext)
        image.title = "TestImage"
        
        
        do {
            try coreData.saveMainContext()
        } catch {
            print("WARNING: Core Data did not save")
        }
    }
}

