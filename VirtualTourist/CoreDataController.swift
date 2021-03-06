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
    
    /// Create ///
    func createPin(dictionary: [NSDictionary], location: CLLocationCoordinate2D) {
        let pin = fetchPinEntity()
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        for item in dictionary {
            let photo = convertNSDictToPhoto(dictionary: item)
            pin.addToHasPhotos(photo)
        }
        let results = saveChanges()
        
        if results.isSucess != true {
            print("WARNING: \(results.error!)")
        }
    }
    
    func addPhotos(photos: [Photo]) {
        for photo in photos {
            managedObjectContext.insert(photo as NSManagedObject)
        }
    }
    
    /// Read ///
    func fetchPhotoEntity() -> Photo {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext)!
        return Photo(entity: entity, insertInto: managedObjectContext)
    }
    

    func fetchPinEntity() -> Pin {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedObjectContext)!
        return Pin(entity: entity, insertInto: managedObjectContext)
    }
    
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
    
    func fetchPhotosFromPinResultsController (pin: Pin) throws -> NSFetchedResultsController<Photo> {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let predicate = NSPredicate(format: "withinPin == %@", pin)
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            throw CoreDataErrors.FetchedResultsControllerNoDataReturned
        }
        
        return fetchResultsController
    }
    
    /// Update ///
    func saveChanges() -> (isSucess: Bool, error: Error?) {
        do {
            try managedObjectContext.save()
            return (true, nil)
        } catch {
            return (false, CoreDataErrors.UnableToSaveContext)
        }
    }
    
    /// Delete ///
    func discardPinChanges() {
        managedObjectContext.rollback()
    }
    
    func deletePin(pin: Pin) {
        managedObjectContext.delete(pin)
    }
    
    func deletePhotosFromPin(pin: Pin) -> (isSuccess: Bool, error: Error?) {
        do {
            let photos = try fetchPhotosFromPinResultsController(pin: pin)
            for photo in photos.fetchedObjects! {
                photos.managedObjectContext.delete(photo)
            }
            do {
                try photos.managedObjectContext.save()
            } catch {
                return (false, CoreDataErrors.UnableToSaveContext)
            }
        } catch {
            return (false, CoreDataErrors.UnableToDeleteObjects)
        }
        return (true, nil)
    }
    
    func deletePhoto(photo: Photo) {
        managedObjectContext.delete(photo as NSManagedObject)
    }
    
    func deletePhotos(photos: [Photo]) {
        for photo in photos {
            managedObjectContext.delete(photo as NSManagedObject)
        }
    }
    
    /// Helper Functions: Conversion ///
    func convertNSDictToPhoto(dictionary: NSDictionary) -> Photo {
        let photo = fetchPhotoEntity()
        if let farmID = dictionary.value(forKey: "farm"),
            let serverID = dictionary.value(forKey: "server"),
            let secret = dictionary.value(forKey: "secret"),
            let id = dictionary.value(forKey: "id") as? String {
            let url = "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret)_t.jpg"
            
            photo.id = id
            photo.url = url
        }
        return photo
    }
    
    func convertNSDictArraytoPhotoArrayWithPin(pin: Pin, dictionaryArray: [NSDictionary]) -> [Photo] {
        var photoArray = [Photo]()
        for dict in dictionaryArray {
            let photo = convertNSDictToPhoto(dictionary: dict)
            photo.withinPin = pin
            photoArray.append(photo)
        }
        return photoArray
    }
}

/// Errors ///
enum CoreDataErrors: Error {
    case FetchedResultsControllerNoDataReturned
    case FailedToAddPin
    case UnableToSaveContext
    case UnableToDeleteObjects
}
