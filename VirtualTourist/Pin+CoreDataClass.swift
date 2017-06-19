//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 6/12/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, hasPhotos: NSOrderedSet?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            if let photos = hasPhotos {
                self.hasPhotos = photos
            }
        } else {
            fatalError("Unable to find Pin entity!")
        }
    }
}
