//
//  Album+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/18/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var name: String?
    @NSManaged public var hasImages: Image?

}
