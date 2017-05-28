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
    let coreData = CoreDataController()
    
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
        guard let count = receivedPin?.hasPhotos?.array.count else {
            return 21
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 4
        return CGSize(width: width - 3, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .blue
        
        let photos = receivedPin?.hasPhotos?.array as! [Photo]
        let photo = photos[(indexPath as NSIndexPath).row]
        let url = URL(string: photo.url!)
        
        downloadImageFromFlikrURL(url: url!, completionHandler: {
            (data, response, error) in
            
            if error == nil {
                // todo: check for data
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
        } else {
            print("new collection")
        }
    }
    
}

// Flikr
extension DetailViewController {
    
    func convertStringToURL(string: String) throws -> URL {
        
        guard let url = URL(string: string) else {
            throw DetailViewControllerErrors.failedToConvertToURL
        }
        
        return url
        
    }
    
    func downloadImageFromFlikrURL(url: URL, completionHandler: @escaping (_ data: Data?,_ repsonse: URLResponse?,_ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            completionHandler(data, response, error)
        }).resume()
    }
    
    func getLocationImagesCompletionHandler(error: Error?, urls: [String]?) -> Void {
        if error == nil {
            // handle error
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                if let urls = urls {
                    print("DetailView received ids: \(urls)")
                } else {
                    print("ERROR: missing returned urls")
                }
            }
        }
    }
}

extension DetailViewController {
    enum DetailViewControllerErrors: Error {
        case failedToConvertToURL
        case ImageDataMissing
        case URLDataMissing
        case PinDataNotReturned
    }
}
