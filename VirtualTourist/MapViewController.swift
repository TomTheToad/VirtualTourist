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
    // let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Fields
    var previousLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mapView delegate
        mapView.delegate = self
        
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
        
        // longPressRecognizer.minimumPressDuration = 1.0
        // mapView.addGestureRecognizer(longPressRecognizer)
        mapView.showsUserLocation = true
    }

    
    func checkForPreviousMapLocation() {
        let previousLatitude = UserDefaults.standard.double(forKey: "latitude")
        let previousLongitude = UserDefaults.standard.double(forKey: "longitude")
        
        print("returned location = lat:\(previousLatitude), long\(previousLongitude)")
        
        // previousLocation = CLLocation(latitude: previousLatitude, longitude: previousLongitude)
        previousLocation = CLLocationCoordinate2DMake(previousLatitude, previousLongitude)
    }
    
    // Configure mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.orange
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 15000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(previousLocation!, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // Configure User Pin drop
    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let thisAnnotation = MKPointAnnotation()
        thisAnnotation.coordinate = touchMapCoordinate
        thisAnnotation.title = "test pin drop"
        
        mapView.addAnnotation(thisAnnotation)
    }
    
    
    // Allow mapView location bubble click through to give student mediaURL in safari.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            presentCollectionView()
        }
    }
    
    
    func dropTestPin() {

        let annotation = MKPointAnnotation()
     
        annotation.coordinate = previousLocation!
        annotation.title = "Test Pin"
        
        print("Annotation: \(annotation.description)")
        
        mapView.addAnnotation(annotation)
    }
    
    
    // Collection View
    func presentCollectionView() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
                print("MESSAGE: Failed to instantiate collection view controller")
                return
        }
        
        controller.receivedMapLocation = previousLocation!
        
        present(controller, animated: false, completion: {
            print("MESSAGE: DetailView Called")
        })
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
}
