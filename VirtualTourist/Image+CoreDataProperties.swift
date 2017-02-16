//
//  Image+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image");
    }

    @NSManaged public var imageData: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var withinAlbum: Album?

}
