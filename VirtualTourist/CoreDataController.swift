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
    
    func fetchPin(location: CLLocationCoordinate2D) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [location.latitude, location.longitude])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            
            return results.last as? Pin
        } catch {
            print("Error fetching Pin")
            return nil
        }
    }
    
    func fetchPins() -> [Pin]? {
        
        do {
            let pins = try managedObjectContext.fetch(Pin.fetchRequest()) as [Pin]
            return pins
        } catch {
            return nil
        }
    }
    
    func fetchPhotoEntity() -> Photo {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext)!
        return Photo(entity: entity, insertInto: managedObjectContext)
    }
    
    func fetchPinEntity() -> Pin {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedObjectContext)!
        return Pin(entity: entity, insertInto: managedObjectContext)
    }
    
    func convertNSDictToPin(dictionary: [NSDictionary], location: CLLocationCoordinate2D) -> Pin {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedObjectContext)!
        let pin = Pin(entity: entity, insertInto: managedObjectContext)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        for item in dictionary {
            let photo = fetchPhotoEntity()
            if let farmID = item.value(forKey: "farm"),
                let serverID = item.value(forKey: "server"),
                let secret = item.value(forKey: "secret"),
                let id = item.value(forKey: "id") as? String {
                let url = "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret)_t.jpg"
                
                photo.url = url
                pin.addToHasPhotos(photo)
            }
        }
        saveChanges()
        return pin
    }

    func saveChanges() {
        do {
            try managedObjectContext.save()
            print("MOC saved")
        } catch {
            print("Unable to save MOC")
        }
    }
    
    func discardPinChanges() {
        managedObjectContext.rollback()
    }
    
    func deletePin(pin: Pin) {
        managedObjectContext.delete(pin)
    }
}
