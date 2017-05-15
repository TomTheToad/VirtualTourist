//
//  Image+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/10/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var url: NSObject?
    @NSManaged public var withinAlbum: Album?

}
