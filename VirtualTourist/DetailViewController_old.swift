//
//  DetailViewController_old.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/22/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController_old: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // Fields
    // Received fields
    var pin = Pin()
    // var altDataSrc = [Photo]()
    
    let photoDataSource = DetailViewDataSource(photoArray: pin.hasPhotos!.array as! [Photo])
    let flikr = FlikrAPIController()
    let coreData = CoreDataController()
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        altDataSrc = pin.hasPhotos?.array as! [Photo]
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure mapView
        mapView.delegate = self
        
        // Configure collectionView
        collectionView!.delegate = self
        collectionView!.dataSource = photoDataSource
        
        // todo: redundant?
        collectionView!.allowsSelection = true
        collectionView!.allowsMultipleSelection = true
        
        setMapViewLocation()
        addToolBar()
    }
    
    func addToolBar() {
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolBarButton = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(toolBarButtonAction))
        toolBarButton.possibleTitles = ["New Collection", "Remove Selected Pictures"]
        toolBarButton.tintColor = UIColor.blue
        
        navigationController?.toolbar.barTintColor = UIColor.white
        
        toolbarItems = [toolBarFlexibleSpace, toolBarButton, toolBarFlexibleSpace]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
}

// MapView
extension DetailViewController: MKMapViewDelegate {
    
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 3000
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            let toolBarItem = toolbarItems?[1]
            toolBarItem?.title = "Remove selected cells"
        } else {
            let toolBarItem = toolbarItems?[1]
            toolBarItem?.title = "New Collection"
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 4
        return CGSize(width: width - 3, height: height)
    }
    
    
    /* CollectionView */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setEditing(true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems!.isEmpty {
            setEditing(false, animated: true)
        }
    }
    
    func toolBarButtonAction() {
        if isEditing {
            print("delete cells: \(collectionView.indexPathsForSelectedItems!)")
            removeObjects()
        } else {
            newPhotoPage()
        }
    }
    
    func removeObjects() {
        
        guard let indexes = collectionView.indexPathsForSelectedItems else {
            // handle error
            print("Nothing to delete")
            return
        }
        
        for index in indexes {
            pin.removeFromHasPhotos(at: index.row)
            altDataSrc.remove(at: index.row)
        }
        
        collectionView.deleteItems(at: indexes)
        collectionView.reloadData()
        setEditing(false, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .blue
        
        // let photo = resultsController.object(at: indexPath) as Photo
        // let photo = pin.hasPhotos?.object(at: indexPath.row) as! Photo
        // let photo = altDataSrc[indexPath.row]
        let photo = photos[indexPath.row]
        
        let url = URL(string: photo.url!)
        
        if let image = photo.image as Data? {
            cell.id = photo.id
            cell.imageView.image = UIImage(data: image)
            cell.activityIndicator.stopAnimating()
        } else {
            
            flikr.downloadImageFromFlikrURL(url: url!, completionHandler: {
                (data, response, error) in
                
                if error == nil {
                    // todo: check for data
                    if let imageData = data {
                        photo.image = NSData(data: imageData)
                        self.coreData.saveChanges()
                    }
                    
                    let photoImage = UIImage(data: data!)
                    DispatchQueue.main.async(execute: { ()-> Void in
                        cell.imageView.image = photoImage
                        cell.activityIndicator.stopAnimating()
                    })
                } else {
                    guard let thisResponse = response else {
                        print("DV: No response")
                        return
                    }
                    
                    print("Response: \(thisResponse)")
                    
                    guard let thisError = error else {
                        print("Error: No error")
                        return
                    }
                    
                    print("Error: \(thisError)")
                }
                
            })
        }
        
        return cell
        
    }
    
}
    
    func newPhotoPage() {
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        do {
            try flikr.getImageArray(location: location, completionHander: {
                (error, dict) in
                if error == nil {
                    guard let photosDictArray = dict else {
                        // todo: handle error
                        return
                    }
                    
                    self.coreData.deletePhotosFromPin(pin: self.pin)
                    // self.removeAllPhotosFromPin()
                    self.altDataSrc.removeAll()
                    
                    let photos = self.coreData.convertNSDictArraytoPhotoArray(dictionaryArray: photosDictArray)
                    
                    let numberOfPhotos = self.collectionView.numberOfItems(inSection: 0)
                    
                    //                    for photo in photos {
                    //                        while self.altDataSrc.count < numberOfPhotos {
                    //                            self.pin.addToHasPhotos(photo)
                    //                            self.altDataSrc.append(photo)
                    //                        }
                    //                    }
                    
                    for photo in photos {
                        if self.altDataSrc.count < numberOfPhotos {
                            self.pin.addToHasPhotos(photo)
                            self.altDataSrc.append(photo)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.updateAllCollectionViewPhotos()
                    })
                }
                // todo: add function to save new photos
                // todo: combine? add error handling
                // self.coreData.savePhotosToCoreData(pin: self.pin, photos: self.altDataSrc)
                self.coreData.saveChanges()
            })
        } catch {
            //todo : handle error
            print("ERROR: newPhotoPage")
        }
    }
    
    func replaceCollectionViewPhoto(indexPath: IndexPath, NewPhoto: Photo ) {
        pin.replaceHasPhotos(at: indexPath.item, with: NewPhoto)
        collectionView.deleteItems(at: [indexPath])
        collectionView.insertItems(at: [indexPath])
    }
    
    // todo: break this into two functions
    func updateAllCollectionViewPhotos() {
        DispatchQueue.main.async(execute: { ()-> Void in
            self.collectionView.performBatchUpdates({ Void in
                self.collectionView.deleteItems(at: self.collectionView.indexPathsForVisibleItems)
                self.collectionView.insertItems(at: self.collectionView.indexPathsForVisibleItems)
            }, completion: {Void in print("MESSAGE: replaceAllCollectionViewPhotos completed") })
        })
    }
    
    func savePin() {
        do {
            try pin.managedObjectContext?.save()
        } catch {
            // todo: handle error
            print("ERROR: Can not save pin")
        }
    }
    
    func removeAllPhotosFromPin() {
        for photo in pin.hasPhotos! {
            pin.removeFromHasPhotos(photo as! Photo)
        }
    }
    
    func convertStringToURL(string: String) throws -> URL {
        
        guard let url = URL(string: string) else {
            throw DetailViewControllerErrors.failedToConvertToURL
        }
        
        return url
        
    }
    
}

extension DetailViewController {
    enum DetailViewControllerErrors: Error {
        case failedToConvertToURL
        case ImageDataMissing
        case URLDataMissing
        case PinDataNotReturned
        case FetchedResultsControllerNil
        case FetchedResultsControllerFailedToRemoveObject
    }
}
