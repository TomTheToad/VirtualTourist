//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/7/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    var lastLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var doDeletePins = false
    let coreData = CoreDataController()
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Configure navigationView
        navigationItem.title = "Virtual Tourist"
        addToolBar()
        
        // Clears selected pin(s)
        deselectAllPins()
        
        // Preload pins
        addAnnotationsFromMemory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mapView delegate
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        
        // Gesture Recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        longPressRecognizer.isEnabled = true
        mapView.addGestureRecognizer(longPressRecognizer)
        
        // Set starting location
        setMapViewLocationUserDefaults()
        
        // Configure core location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()

    }
    
    /*** UI ***/
    func addToolBar() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ShowToolBar(sender:)))
        
        navigationItem.rightBarButtonItem = editButton
        
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBarButtonLabel = UIBarButtonItem(title: "Select Pins to Delete", style: .plain, target: self, action: nil)
        toolBarButtonLabel.tintColor = UIColor.white
        
        navigationController?.toolbar.barTintColor = UIColor.red
        toolbarItems = [toolBarFlexibleSpace, toolBarButtonLabel, toolBarFlexibleSpace]
    }
    
    func ShowToolBar(sender: UIBarButtonItem) {
        if navigationController?.toolbar.isHidden != false {
            navigationController?.setToolbarHidden(false, animated: true)
            doDeletePins = true
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            doDeletePins = false
        }
    }
    
    func HideToolBar() {
        navigationController?.setToolbarHidden(true, animated: false)
        doDeletePins = false
    }
    
    /*** MapView ***/
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // saveLocationToCoreData(location: mapView.centerCoordinate)
        saveLocationToUserDefaults(location: mapView.centerCoordinate)
        print("MESSAGE: mapView region did change")
    }
    
    // Configure mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.orange
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let location = view.annotation?.coordinate else {
            print("Location Missing")
            return
        }
        
        guard let album = coreData.fetchAlbum(location: location) else {
            print("Album not returned from coreData")
            return
        }
        
        if doDeletePins == false {
            DispatchQueue.main.async(execute: { ()-> Void in
                self.presentDetailView(location: location, album: album)
            })
        } else {
            guard let annotation = view.annotation else {
                print("Warning: Cannot delete view. View not found")
                return
            }

            coreData.deleteAlbum(album: album)
            coreData.saveChanges()
            mapView.removeAnnotation(annotation)
            print("Album deleted")
            
        }
    }
    
    func setMapViewLocationUserDefaults() {
        let regionRadius: CLLocationDistance = 15000
        let previousLocation: CLLocationCoordinate2D? = {
            
            guard let lat = UserDefaults.standard.object(forKey: "latitude") as? CLLocationDegrees else {
                // do something
                return nil
            }
            guard let long = UserDefaults.standard.object(forKey: "longitude") as? CLLocationDegrees else {
                // do something
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }()
        
        if let location = previousLocation {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    // todo: change method to touch and another to add
    func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            HideToolBar()
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoords
            annotation.title = "User Added Point"
            
            lastLocation = newCoords
            mapView.addAnnotation(annotation)
            getImages(mapLocation: newCoords)
        }
    }
    
    func addAnnotationsFromMemory() {

        guard let albums = coreData.fetchAlbums() else {
            // todo: throw an error
            print("Warning: failed to load albums")
            return
        }
        
        for album in albums {
            let annotation = MKPointAnnotation()
            annotation.coordinate = (CLLocationCoordinate2DMake(album.latitude, album.longitude))
            if doesMapViewContainAnnotation(annotation: annotation) == false {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func doesMapViewContainAnnotation(annotation: MKAnnotation) -> Bool {
        if mapView.annotations.isEmpty {
            return false
        }
        
        for item in mapView.annotations {
            if item.coordinate.latitude == annotation.coordinate.latitude, item.coordinate.longitude == annotation.coordinate.longitude {
                return true
            }
        }
        
        return false
    }
    
    // helper
    // Make sure any pins are deselected
    func deselectAllPins() {
        let selectedAnnotations = mapView.selectedAnnotations
        for pinAnnotation in selectedAnnotations {
            mapView.deselectAnnotation(pinAnnotation, animated: false)
        }
    }
}


extension MapViewController {
    func presentDetailView(location: CLLocationCoordinate2D, images: [NSDictionary]) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        controller.receivedMapLocation = location
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentDetailView(location: CLLocationCoordinate2D, album: Album) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        controller.receivedMapLocation = location
        controller.receivedalbum = album
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MapViewController {
    
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
                // todo: Album never sets location
                if let images = imageItems {
                    let album = coreData.convertNSDictToAlbum(dictionary: images, location: lastLocation!)
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.presentDetailView(location: self.lastLocation!, album: album)
                    })
                } else {
                    print("ERROR: missing returned urls")
                    // handle error, send alert
                }
            }
        }
    }

}


extension MapViewController {
    func saveLocationToUserDefaults(location: CLLocationCoordinate2D) {
        UserDefaults.standard.setValuesForKeys(["latitude": location.latitude])
        UserDefaults.standard.setValuesForKeys(["longitude": location.longitude])
        UserDefaults.standard.synchronize()
    }
}

extension MapViewController {
    enum MapViewControllerError: Error {
        case previousLocationMissing
    }
}
