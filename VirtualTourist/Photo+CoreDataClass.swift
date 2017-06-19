//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 6/8/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    convenience init(image: NSData?, url: String, id: String, withinPin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "photo", in: context) {
            self.init(entity: ent, insertInto: context)
            if let thisImage = image {
                self.image = thisImage
            }
            
            self.url = url
            self.id = id
            self.withinPin = withinPin
            
        } else {
            fatalError("Unable to find Photo entity!")
        }
    }

}
