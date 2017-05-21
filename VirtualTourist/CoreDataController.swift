//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 5/14/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//
// todo: Add robust error handling and custom errors

import Foundation
import CoreData
import MapKit

class CoreDataController {
    let managedObjectContext: NSManagedObjectContext = {
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
            let results = try managedObjectContext.fetch(fetchRequest)
            
            return results.last as? Album
        } catch {
            print("Error fetching album")
            return nil
        }
    }
    
    func fetchAlbums() -> [Album]? {
        
        do {
            let albums = try managedObjectContext.fetch(Album.fetchRequest()) as [Album]
            return albums
        } catch {
            return nil
        }
    }
    
    func fetchImageEntity() -> Image {
        let entity = NSEntityDescription.entity(forEntityName: "Image", in: managedObjectContext)!
        return Image(entity: entity, insertInto: managedObjectContext)
    }
    
    func fetchAlbumEntity() -> Album {
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedObjectContext)!
        return Album(entity: entity, insertInto: managedObjectContext)
    }
    
    func convertNSDictToAlbum(dictionary: [NSDictionary], location: CLLocationCoordinate2D) -> Album {
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedObjectContext)!
        let album = Album(entity: entity, insertInto: managedObjectContext)
        album.latitude = location.latitude
        album.longitude = location.longitude
        
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
        saveChanges()
        return album
    }

    func saveChanges() {
        do {
            try managedObjectContext.save()
            print("MOC saved")
        } catch {
            print("Unable to save MOC")
        }
    }
    
    func discardAlbumChanges() {
        managedObjectContext.rollback()
    }
    
    func deleteAlbum(album: Album) {
        managedObjectContext.delete(album)
    }
}
