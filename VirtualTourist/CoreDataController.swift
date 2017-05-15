//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/14/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CoreDataController {
    let managedObectContext = {
       return AppDelegate().persistentContainer.viewContext
    }()
    
    func fetchAlbum(location: CLLocationCoordinate2D) -> Album {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [location.latitude, location.longitude])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObectContext.fetch(fetchRequest).last as! Album
            return results
        } catch {
            let album = Album(entity: Album.entity(), insertInto: managedObectContext)
            return album
        }
    }
    
    func fetchImageEntity() -> Image {
        return Image(entity: Image.entity(), insertInto: managedObectContext)
    }
}
