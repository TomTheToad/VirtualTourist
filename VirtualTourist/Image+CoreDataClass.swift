//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/14/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    
    convenience init(id: String, context: NSManagedObjectContext) {
        
        if let imageEntity = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: imageEntity, insertInto: context)
            self.id = id
        } else {
            fatalError("Unable to find Image Entity!")
        }
    }
}
