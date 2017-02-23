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
        
        let image = Image()
        image.title = "TestImage"
        
        let coreData = appDelegate.coreDataStack
        
        do {
            try coreData.saveMainContext()
        } catch {
            print("WARNING: Core Data did not save")
        }
    }
}

