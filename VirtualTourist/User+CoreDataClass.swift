//
//  User+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/25/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

    convenience init(id: Int16, lastLatitude: String, lastLongitude: String, context: NSManagedObjectContext) {
        if let userEntity = NSEntityDescription.entity(forEntityName: "User", in: context) {
            self.init(entity: userEntity, insertInto: context)
            self.id = id
            self.lastLatitude = lastLatitude
            self.lastLongitude = lastLongitude
        } else {
            fatalError("Unable to find User Entity")
        }
    }
}
