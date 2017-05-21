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
    }
}
