//
//  Album+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/29/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var hasImages: Image?
    @NSManaged public var withinUser: NSManagedObject?

}
