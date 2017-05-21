//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/21/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var hasPhotos: NSOrderedSet?

}

// MARK: Generated accessors for hasPhotos
extension Pin {

    @objc(insertObject:inHasPhotosAtIndex:)
    @NSManaged public func insertIntoHasPhotos(_ value: Photo, at idx: Int)

    @objc(removeObjectFromHasPhotosAtIndex:)
    @NSManaged public func removeFromHasPhotos(at idx: Int)

    @objc(insertHasPhotos:atIndexes:)
    @NSManaged public func insertIntoHasPhotos(_ values: [Photo], at indexes: NSIndexSet)

    @objc(removeHasPhotosAtIndexes:)
    @NSManaged public func removeFromHasPhotos(at indexes: NSIndexSet)

    @objc(replaceObjectInHasPhotosAtIndex:withObject:)
    @NSManaged public func replaceHasPhotos(at idx: Int, with value: Photo)

    @objc(replaceHasPhotosAtIndexes:withHasPhotos:)
    @NSManaged public func replaceHasPhotos(at indexes: NSIndexSet, with values: [Photo])

    @objc(addHasPhotosObject:)
    @NSManaged public func addToHasPhotos(_ value: Photo)

    @objc(removeHasPhotosObject:)
    @NSManaged public func removeFromHasPhotos(_ value: Photo)

    @objc(addHasPhotos:)
    @NSManaged public func addToHasPhotos(_ values: NSOrderedSet)

    @objc(removeHasPhotos:)
    @NSManaged public func removeFromHasPhotos(_ values: NSOrderedSet)

}
