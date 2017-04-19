//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/18/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


public class Image: NSManagedObject {
    
    convenience init(id: String, url: String, context: NSManagedObjectContext) {
        if let imageEntity = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: imageEntity, insertInto: context)
            self.id = id
            self.url = url
        } else {
            fatalError("Unable to find Image Entity!")
        }
    }
}
