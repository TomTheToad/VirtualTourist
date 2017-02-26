//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/26/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    
    convenience init(title: String, imageData: NSData, context: NSManagedObjectContext) {
        
        if let imageEntity = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: imageEntity, insertInto: context)
            self.title = title
            self.imageData = imageData
        } else {
            fatalError("Unable to find Image Entity!")
        }
    }

}
