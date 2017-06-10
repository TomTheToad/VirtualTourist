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

class DetailViewController: UIViewController {
    
    // Fields
    var receivedMapLocation: CLLocationCoordinate2D?
    var receivedPin: Pin?
    
    let flikr = FlikrAPIController()
    let coreData = CoreDataController()
    
    var resultsController = NSFetchedResultsController<Photo>()
    var pin = Pin()
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure mapView
        mapView.delegate = self
        
        // Configure collectionView
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
        // todo: redundant?
        collectionView!.allowsSelection = true
        collectionView!.allowsMultipleSelection = true
        
        setMapViewLocation(location: receivedMapLocation)
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

    func setMapViewLocation(location: CLLocationCoordinate2D?) {
        let regionRadius: CLLocationDistance = 3000
        
        guard let thisLocation = location else {
            // todo: create an error
            print("WARNING: Missing map location")
            return
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(thisLocation, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = thisLocation
        mapView.addAnnotation(annotation)
    }
    
}

// CollectionView
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsController.fetchedObjects?.count ?? 21
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 4
        return CGSize(width: width - 3, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .blue
        
        let photo = resultsController.object(at: indexPath) as Photo
        
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
    
    // todo: clean this up
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
            collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems!)
            // collectionView.indexPathsForSelectedItems.fla
            collectionView.reloadData()
        } else {
            print("new collection")
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
    }
}
