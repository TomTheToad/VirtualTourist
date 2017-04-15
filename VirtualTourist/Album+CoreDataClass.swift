//
//  Album+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/14/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject {
    
    convenience init(name: String, latitude: String, longitude: String, context: NSManagedObjectContext) {
        
        if let albumEntity = NSEntityDescription.entity(forEntityName: "Album", in: context) {
            self.init(entity: albumEntity, insertInto: context)
            self.name = name
        } else {
            fatalError("Unable to find Album Entity!")
        }
    }

}
