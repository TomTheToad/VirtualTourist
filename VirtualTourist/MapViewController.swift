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
    var previousLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var doDeletePins = false
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Virtual Tourist"
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ShowToolBar(sender:)))

        
        navigationItem.rightBarButtonItem = editButton
        
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBarButtonLabel = UIBarButtonItem(title: "Select Pins to Delete", style: .plain, target: self, action: nil)
        toolBarButtonLabel.tintColor = UIColor.white
        
        navigationController?.toolbar.barTintColor = UIColor.red
        toolbarItems = [toolBarFlexibleSpace, toolBarButtonLabel, toolBarFlexibleSpace]
        // navigationController?.setToolbarHidden(true, animated: false)
        
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
        
        // Check UserDefaults for previous location
        checkForPreviousMapLocation()
        
        // Set starting location
        setMapViewLocation()
        
        // Configure core location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        // Test functions below
        dropTestPin()
        mapView.showsUserLocation = true
    }

    
    func checkForPreviousMapLocation() {
        let previousLatitude = UserDefaults.standard.double(forKey: "latitude")
        let previousLongitude = UserDefaults.standard.double(forKey: "longitude")
        
        print("returned location = lat:\(previousLatitude), long\(previousLongitude)")
        
        previousLocation = CLLocationCoordinate2DMake(previousLatitude, previousLongitude)
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
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(previousLocation!, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if doDeletePins == true {
            mapView.removeAnnotation(view.annotation!)
        } else {
            // presentCollectionView()
            // todo: change to current pin location
            getLocationImageIDs(mapLocation: previousLocation!)
            
        }
    }
    

    func dropTestPin() {

        let annotation = MKPointAnnotation()
     
        annotation.coordinate = previousLocation!
        annotation.title = "Test Pin"
        
        print("Annotation: \(annotation.description)")
        
        mapView.addAnnotation(annotation)
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
    
    func getLocationImageIDs(mapLocation: CLLocationCoordinate2D) {
        // Get images
        // todo: will probably need to update the api to use
        // a fetchedResultsController
        
        let latitude: String = (mapLocation.latitude.description)
        print("latitude: \(latitude)")
        let longitude: String = (mapLocation.longitude.description)
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
                    DispatchQueue.main.async(execute: { ()-> Void in
                        self.presentCollectionView(location: self.previousLocation!, urls: urls)
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
        
        controller.receivedMapLocation = previousLocation!
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentCollectionView(location: CLLocationCoordinate2D, urls: [String]) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        controller.receivedMapLocation = location
        controller.receivedURLS = urls
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
}
