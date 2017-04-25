//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/7/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    var lastLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var doDeletePins = false
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Configure navigationView
        navigationItem.title = "Virtual Tourist"
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ShowToolBar(sender:)))

        navigationItem.rightBarButtonItem = editButton
        
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBarButtonLabel = UIBarButtonItem(title: "Select Pins to Delete", style: .plain, target: self, action: nil)
        toolBarButtonLabel.tintColor = UIColor.white
        
        navigationController?.toolbar.barTintColor = UIColor.red
        toolbarItems = [toolBarFlexibleSpace, toolBarButtonLabel, toolBarFlexibleSpace]
        
        // Clears selected pin(s)
        deselectAllPins()
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
        setMapViewLocation()
        
        // Configure core location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        // Test functions below
        // dropTestPin()
        mapView.showsUserLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveLocationToUserDefaults(location: mapView.centerCoordinate)
    }
    
    // todo: not working
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        saveLocationToUserDefaults(location: mapView.centerCoordinate)
    }
    
    func saveLocationToUserDefaults(location: CLLocationCoordinate2D) {
        UserDefaults.standard.setValuesForKeys(["latitude": location.latitude])
        UserDefaults.standard.setValuesForKeys(["longitude": location.longitude])
        UserDefaults.standard.synchronize()
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
    
    func setMapViewLocation() {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if doDeletePins == true {
            mapView.removeAnnotation(view.annotation!)
        } else {
            lastLocation = view.annotation?.coordinate
            presentCollectionView()
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
//    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
//        if gestureRecognizer.state == UIGestureRecognizerState.Began {
//            var touchPoint = gestureRecognizer.locationInView(map)
//            var newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = newCoordinates
//            
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                if error != nil {
//                    println("Reverse geocoder failed with error" + error.localizedDescription)
//                    return
//                }
//                
//                if placemarks.count > 0 {
//                    let pm = placemarks[0] as! CLPlacemark
//                    
//                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title = pm.thoroughfare + ", " + pm.subThoroughfare
//                    annotation.subtitle = pm.subLocality
//                    self.map.addAnnotation(annotation)
//                    println(pm)
//                }
//                else {
//                    annotation.title = "Unknown Place"
//                    self.map.addAnnotation(annotation)
//                    println("Problem with the data received from geocoder")
//                }
//                places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
//            })
//        }
//    }
    
    // todo: change method to touch and another to add
    func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoords
            annotation.title = "User Added Point"
            mapView.addAnnotation(annotation)
            getImages(mapLocation: newCoords)
        }
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
    
    // Fields
    // var receivedMapLocation: CLLocationCoordinate2D?
    
    func getImages(mapLocation: CLLocationCoordinate2D) {
        // Get images
        // todo: will probably need to update the api to use
        // a fetchedResultsController
        
        let latitude: String = (mapLocation.latitude.description)
        print("latitude: \(latitude)")
        let longitude: String = (mapLocation.longitude.description)
        print("longitude: \(longitude)")
        
        lastLocation = mapLocation
        
        let flickr = FlickrAPIController()
        
        do {
            try flickr.getImageArray(latitude: latitude, longitude: longitude, completionHander: getImagesCompletionHandler)
        } catch {
            // Handle error
            print("ERROR: Something Happened")
        }
    }
    
    func getImagesCompletionHandler(error: Error?, imageItems: [ImageItem]?) -> Void {
        if error == nil {
            // handle error
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                if let images = imageItems {
                    print("DetailView received ids: \(images)")
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.presentCollectionView(location: self.lastLocation!, imageItems: images)
                        print("lastLocation: \(self.lastLocation!)")
                    })
                } else {
                    print("ERROR: missing returned urls")
                }
            }
        }
    }
}

extension MapViewController {
    
    // Collection View
    func presentCollectionView() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        controller.receivedMapLocation = lastLocation!
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentCollectionView(location: CLLocationCoordinate2D, imageItems: [ImageItem]) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        
        controller.receivedMapLocation = location
        controller.receivedImages = imageItems
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MapViewController {
    enum MapViewControllerError: Error {
        case previousLocationMissing
    }
}
