//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/22/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {
    
    // Dependencies
    let flikr = FlikrAPIController()
    let coreData = CoreDataController()
    
    // Received fields
    var pin = Pin()
    
    // Data Source
    var photoSource = PhotoDataSource()
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set data
        photoSource.photos = pin.hasPhotos?.array as! [Photo]
        
        // Configure mapView
        mapView.delegate = self
        
        // Configure collectionView
        collectionView!.delegate = self
        collectionView!.dataSource = photoSource
        
        collectionView!.allowsMultipleSelection = true
        
        setMapViewLocation()
        addToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coreData.saveChanges()
    }
    
    /// Configure View ///
    func addToolBar() {
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolBarButton = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(toolBarButtonAction))
        toolBarButton.possibleTitles = ["New Collection", "Remove Selected Pictures"]
        toolBarButton.tintColor = UIColor.blue
        
        navigationController?.toolbar.barTintColor = UIColor.white
        
        toolbarItems = [toolBarFlexibleSpace, toolBarButton, toolBarFlexibleSpace]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func toolBarButtonAction() {
        if isEditing {
            print("delete cells: \(collectionView.indexPathsForSelectedItems!)")
            removeObjects()
        } else {
            newPhotoPage()
        }
    }
    
    /// Configure MapView ///
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 3000
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    // Configure CollectionView ///
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setEditing(true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems!.isEmpty {
            setEditing(false, animated: true)
        }
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
    
    /// Photo Collection Editing ///
    func removeObjects() {
        
        guard let indexArray = collectionView.indexPathsForSelectedItems else {
            // handle error
            print("Nothing to delete")
            return
        }
        
        photoSource.deletePhotos(indexArray: indexArray)
        collectionView.deleteItems(at: indexArray)
        deletePhotosAssociatedWithPin(pin: pin, indexPathArray: indexArray)
        setEditing(false, animated: true)
    }
    
    /// Replace CollectionView Page functionality
    func newPhotoPage() {
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        do {
            try flikr.getImageArray(location: location, completionHander: {
            (error, dict) in
                if error == nil {
                    self.coreData.deletePhotos(photos: self.photoSource.photos)
                    
                    guard let photosDictArray = dict else {
                        // todo: handle error
                        return
                    }
                    
                    let newPhotos = self.coreData.convertNSDictArraytoPhotoArrayWithPin(pin: self.pin, dictionaryArray: photosDictArray)
                    
                    self.photoSource.replacePhotos(photoArray: newPhotos)
                    self.coreData.addPhotos(photos: newPhotos)
                    
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.collectionView.reloadData()
                        self.updateAllCollectionViewPhotos()
                    })
                    
                } else {
                    // todo: handle this
                    print("Pin error has ocurred")
                }
            })
        } catch {
            //todo : handle error
            print("ERROR: newPhotoPage")
        }
    }
    
    func replaceCollectionViewPhoto(indexPath: IndexPath, NewPhoto: Photo ) {
        // outsource this pin.replaceHasPhotos(at: indexPath.item, with: NewPhoto)
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
    
    func deletePhotosAssociatedWithPin(pin: Pin, indexPathArray: [IndexPath]) {
        for indexPath in indexPathArray {
            let photo = pin.hasPhotos?.array[indexPath.row] as! Photo
            coreData.deletePhoto(photo: photo)
        }
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
