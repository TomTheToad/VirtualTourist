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
    var album: Album?
    
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
        
        // todo: handle missing coordinate?
        album = {
           coreData.fetchAlbum(location: receivedMapLocation!)
        }()
        
        if album?.hasImages?.array.isEmpty == true {
            // get images from Flickr
            getImages(mapLocation: receivedMapLocation!)
        }

        setMapViewLocation(location: receivedMapLocation)
    }
}

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
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (album?.hasImages?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 4
        return CGSize(width: width - 3, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .blue
        
        guard let imageURLS = album?.mutableOrderedSetValue(forKey: "url") else {
            // todo: handle error
            return cell
        }
        
        let url = imageURLS[(indexPath as NSIndexPath).row] as! URL
        downloadImageFromFlikrURL(url: url, completionHandler: {
            (data, response, error) in
            
            if error == nil {
                // todo: check for data
                let image = UIImage(data: data!)
                DispatchQueue.main.async(execute: { ()-> Void in
                    // thisImageView.image = UIImage(data: data!)
                    cell.imageView.image = image
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
}

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
    
//    func getLocationImageIDs() {
//        // Get images
//        // todo: will probably need to update the api to use
//        // a fetchedResultsController
//        
//        let latitude: String = (receivedMapLocation?.latitude.description)!
//        print("latitude: \(latitude)")
//        let longitude: String = (receivedMapLocation?.longitude.description)!
//        print("longitude: \(longitude)")
//        
//        let flickr = FlickrAPIController()
//        
//        do {
//            try flickr.getPhotosIDList(latitude: latitude, longitude: longitude, completionHander: getLocationImagesCompletionHandler)
//        } catch {
//            // Handle error
//            print("ERROR: Something Happened")
//        }
//    }
    
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
    
    // FLICKRAPI
    
    func getImages(mapLocation: CLLocationCoordinate2D) {
        // Get images
        // todo: will probably need to update the api to use
        // a fetchedResultsController
        
        let latitude: String = (mapLocation.latitude.description)
        print("latitude: \(latitude)")
        let longitude: String = (mapLocation.longitude.description)
        print("longitude: \(longitude)")
        
        let flickr = FlickrAPIController()
        
        do {
            try flickr.getImageArray(latitude: latitude, longitude: longitude, completionHander: getImagesCompletionHandler)
        } catch {
            // todo: Handle error
            print("ERROR: Something Happened")
        }
    }
    
    func getImagesCompletionHandler(error: Error?, imageItems: [NSDictionary]?) -> Void {
        if error == nil {
            // handle error
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                // handle error, send alert
            } else {
                if let images = imageItems {
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.populateAlbum(dictionary: images)
                    })
                } else {
                    print("ERROR: missing returned urls")
                    // handle error, send alert
                }
            }
        }
    }
    
    func populateAlbum(dictionary: [NSDictionary]) {
        for item in dictionary {
            let image = coreData.fetchImageEntity()
            image.id = item.value(forKey: "id") as? String
        }
    }
}

extension DetailViewController {
    enum DetailViewControllerErrors: Error {
        case failedToConvertToURL
        case ImageDataMissing
        case URLDataMissing
    }
}
