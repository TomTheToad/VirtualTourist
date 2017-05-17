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
    let managedObectContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            // todo: handle this
            fatalError("Internal application error")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetchAlbum(location: CLLocationCoordinate2D) -> Album? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [location.latitude, location.longitude])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObectContext.fetch(fetchRequest)
            
            return results.last as? Album
        } catch {
            // todo: throw error
            return nil
        }
    }
    
    func fetchImageEntity() -> Image {
        return Image(entity: Image.entity(), insertInto: managedObectContext)
    }
    
    func fetchAlbumEntity() -> Album {
        return Album(entity: Album.entity(), insertInto: managedObectContext)
    }
    
    func converNSDictToAlbum(dictionary: [NSDictionary]) -> Album {
        let album = Album(entity: Album.entity(), insertInto: managedObectContext)
        
        for item in dictionary {
            let image = fetchImageEntity()
            if let farmID = item.value(forKey: "farm"),
                let serverID = item.value(forKey: "server"),
                let secret = item.value(forKey: "secret"),
                let id = item.value(forKey: "id") as? String {
                let url = "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret)_t.jpg"
                
                image.url = url
                album.addToHasImages(image)
            }
        }
        return album
    }

    func saveAlbumChanges() {
        do {
            try managedObectContext.save()
        } catch {
            //todo: throw error
        }
    }
    
    func discardAlbumChanges() {
        managedObectContext.rollback()
    }
}
