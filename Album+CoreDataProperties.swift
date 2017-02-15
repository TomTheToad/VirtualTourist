//
//  Album+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/14/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData
import 

extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album");
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var hasImages: Image?

}
