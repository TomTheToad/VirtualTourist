//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/22/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    // Fields
    var receivedMapLocation: CLLocationCoordinate2D?
    var receivedURLS: [String]?
    
    var receivedImageIDs: NSDictionary?
    
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
        
        // TEST
        // getLocationImageIDs()
        
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
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 4
        return CGSize(width: width - 3, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.green
        
        // let thisImageView = cell.imageView!
        
        guard let id = receivedURLS?[(indexPath as NSIndexPath).row] else {
            print("ERROR: NO id received")
            cell.textLabel!.text = "broken image"
            return cell
        }
        
        do {
            let url = try convertStringToURL(string: id)
            downloadImageFromFlikrURL(url: url, completionHandler: {
                (data, response, error) in
                
                if error == nil {
                    // todo: check for data
                    DispatchQueue.main.async(execute: { ()-> Void in
                        // thisImageView.image = UIImage(data: data!)
                        cell.imageView.image = UIImage(data: data!)
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
        } catch {
            cell.textLabel!.text = "broken image"
        }
        
        
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
    
    func getLocationImageIDs() {
        // Get images
        // todo: will probably need to update the api to use
        // a fetchedResultsController
        
        let latitude: String = (receivedMapLocation?.latitude.description)!
        print("latitude: \(latitude)")
        let longitude: String = (receivedMapLocation?.longitude.description)!
        print("longitude: \(longitude)")
        
        let flickr = FlickrAPIController()
        
        do {
            try flickr.getPhotosIDList(latitude: latitude, longitude: longitude, completionHander: getLocationImagesCompletionHandler)
        } catch {
            // Handle error
            print("ERROR: Something Happened")
        }
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
    }
}
