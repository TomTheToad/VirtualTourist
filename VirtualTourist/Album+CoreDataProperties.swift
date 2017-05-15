//
//  Album+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/10/17.
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
    @NSManaged public var hasImages: NSOrderedSet?

}

// MARK: Generated accessors for hasImages
extension Album {

    @objc(insertObject:inHasImagesAtIndex:)
    @NSManaged public func insertIntoHasImages(_ value: Image, at idx: Int)

    @objc(removeObjectFromHasImagesAtIndex:)
    @NSManaged public func removeFromHasImages(at idx: Int)

    @objc(insertHasImages:atIndexes:)
    @NSManaged public func insertIntoHasImages(_ values: [Image], at indexes: NSIndexSet)

    @objc(removeHasImagesAtIndexes:)
    @NSManaged public func removeFromHasImages(at indexes: NSIndexSet)

    @objc(replaceObjectInHasImagesAtIndex:withObject:)
    @NSManaged public func replaceHasImages(at idx: Int, with value: Image)

    @objc(replaceHasImagesAtIndexes:withHasImages:)
    @NSManaged public func replaceHasImages(at indexes: NSIndexSet, with values: [Image])

    @objc(addHasImagesObject:)
    @NSManaged public func addToHasImages(_ value: Image)

    @objc(removeHasImagesObject:)
    @NSManaged public func removeFromHasImages(_ value: Image)

    @objc(addHasImages:)
    @NSManaged public func addToHasImages(_ values: NSOrderedSet)

    @objc(removeHasImages:)
    @NSManaged public func removeFromHasImages(_ values: NSOrderedSet)

}
