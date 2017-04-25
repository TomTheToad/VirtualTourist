//
//  User+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 4/25/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var lastLatitude: String?
    @NSManaged public var lastLongitude: String?
    @NSManaged public var id: Int16
    @NSManaged public var hasAlbums: NSSet?

}

// MARK: Generated accessors for hasAlbums
extension User {

    @objc(addHasAlbumsObject:)
    @NSManaged public func addToHasAlbums(_ value: Album)

    @objc(removeHasAlbumsObject:)
    @NSManaged public func removeFromHasAlbums(_ value: Album)

    @objc(addHasAlbums:)
    @NSManaged public func addToHasAlbums(_ values: NSSet)

    @objc(removeHasAlbums:)
    @NSManaged public func removeFromHasAlbums(_ values: NSSet)

}
