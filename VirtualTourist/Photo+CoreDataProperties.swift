//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/21/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var withinPin: Pin?

}
