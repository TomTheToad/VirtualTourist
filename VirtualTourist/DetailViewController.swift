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
        getLocationImageIDs()
        
    }

}

extension DetailViewController: MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        setMapViewLocation()
    }
    
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 3000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(receivedMapLocation!, regionRadius, regionRadius)
        
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
        
        // let id = receivedImageIDs?["\(indexPath)"] as! NSDictionary
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.green
        cell.textLabel!.text = "\((indexPath as NSIndexPath).row)"
        // cell.textLabel!.text = id.value(forKeyPath: "id") as! String?
        
        return cell
    }
    
}

extension DetailViewController {
    
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
